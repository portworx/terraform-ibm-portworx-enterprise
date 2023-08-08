#!/bin/bash

# Check if portworx helm charts are installed and the chart status
# helm history portworx (Find the status etc)

# if installed, then configure the max storage node per zone

# Wait for the pods to be restarted
function version { printf "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

NAMESPACE=$1
PX_CLUSTER_NAME=$2
PROMETHEUS_URL=$3
SCALE_PERCENTAGE_THRESHOLD=$4
SCALE_PERCENTAGE=$5
MAX_CAPACITY=$6
SLEEP_TIME=30

DIVIDER="\n*************************************************************************\n"
HEADER="$DIVIDER*\t\tConfigure Requested to Portworx Enterprise ${IMAGE_VERSION}\t\t*$DIVIDER"

DESIRED=0
READY=0
JSON=0

# Check the Helm Chart Summary
printf "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

CMD="helm"
HELM_VER="v3.10.3"
# Command is empty for v2 (--short fails) and also empty for v3 before v3.4 (where --force-update was introduced)
VERSION=$(helm version --short 2>/dev/null | grep 'v3\.' | grep -v 'v3\.0\.' | grep -v 'v3\.1\.' | grep -v 'v3\.2\.' | grep -v 'v3\.3\.')
if [ "$VERSION" == "" ]; then
    printf "[WARN] Helm v3 is not installed, migrating to $HELM_VER..."
    mkdir /tmp/helm3
    wget https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz -O /tmp/helm3/helm-${HELM_VER}-linux-amd64.tar.gz -q
    tar -xzf /tmp/helm3/helm-${HELM_VER}-linux-amd64.tar.gz -C /tmp/helm3/
    CMD="/tmp/helm3/linux-amd64/helm"
    $CMD version
fi

# Get the Helm status
if ! JSON=$($CMD history portworx -n ${NAMESPACE} -o json | jq '. | last'); then
    printf "[ERROR] Helm couldn't find Portworx Installation, will not proceed with the upgrade!! Please install portworx and then try to upgrade.\n"
    exit 1
else
    printf "$HEADER*\t\t\t\tHelm Chart Summary\t\t\t*$DIVIDER\n$JSON$DIVIDER"
fi

# Check if portworx ds is there, if there,  get the ds details else, exit with error
# Store the number of desired and ready pods
# Show the current pods and ds status
printf "[INFO] Validating Portworx Cluster Status...\n"
if ! sc_state=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE}); then
    printf "[ERROR] Portworx Storage Cluster Not Found, will not proceed with the upgrade!! Please install Portworx Enterprise and then try to upgrade.\n"
    exit 1
else
    STATUS=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status.phase}')
    if [ "$STATUS" == "Online" ] || [ "$STATUS" == "Running" ]; then
        state=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status}' | jq)
        printf "[CHECK PASSED] Portworx Storage Cluster is Online.\n$state\n"
    else
        printf "[ERROR] Portworx Storage Cluster is not Online. Cluster Status: ($STATUS), will not proceed with the upgrade!!\n"
        exit 1

    fi
fi

# Configure kubeconfig
# Get helm binary over the internet, install helm v3.3.0
# Trigger the helm upgrade

AUTOPILOT_SPEC=/tmp/autopilot.yaml
printf "[INFO] get autopilot yaml"
curl "https://install.portworx.com/?comp=autopilot" >$AUTOPILOT_SPEC
printf "[INFO] setting up prometheus url\n"
PROMETHEUS_URL=http://prometheus:9091
PROMETHEUS_URL_LINE_NO=$(grep -n 'http://prometheus:9090' ${AUTOPILOT_SPEC} | cut -d ':' -f1)
if [ "$PROMETHEUS_URL_LINE_NO" != "" ]; then
    PROMETHEUS_URL_LINE=$(grep 'http://prometheus:9090' ${AUTOPILOT_SPEC})
    REPLACED_LINE=${PROMETHEUS_URL_LINE//http\:\/\/prometheus:9090/$PROMETHEUS_URL}
    REPLACED_LINE=${REPLACED_LINE//\//\\\/}
    REPLACED_LINE=${REPLACED_LINE//\:/\\\:}
    FIND_AND_REPLACE="${PROMETHEUS_URL_LINE_NO}s/.*/${REPLACED_LINE}/"
    sed -i -e "${FIND_AND_REPLACE}" $AUTOPILOT_SPEC
fi
printf "[INFO] setting up icr.io\n"
ICR_URL="image: icr.io/ext/portworx/autopilot:"
ICR_URL_LINE_NO=$(grep -n 'image: portworx/autopilot:' ${AUTOPILOT_SPEC} | cut -d ':' -f1)
if [ "$ICR_URL_LINE_NO" != "" ]; then
    ICR_URL_LINE=$(grep 'image: portworx/autopilot:' ${AUTOPILOT_SPEC})
    REPLACED_LINE=${ICR_URL_LINE//image\: portworx\/autopilot\:/$ICR_URL}
    REPLACED_LINE=${REPLACED_LINE//\//\\\/}
    REPLACED_LINE=${REPLACED_LINE//\:/\\\:}
    FIND_AND_REPLACE="${ICR_URL_LINE_NO}s/.*/${REPLACED_LINE}/"
    sed -i -e "${FIND_AND_REPLACE}" $AUTOPILOT_SPEC
fi
printf "[INFO] apply autopilot yaml\n"
kubectl -n $NAMESPACE apply -f $AUTOPILOT_SPEC

if [[ $? -eq 0 ]]; then
    printf "[INFO] Autopilot will be up and running in a while!!\n"
else
    printf "[ERROR] Failed to install autopilot!!\n"
    exit 1
fi

printf "[INFO] Inflating default autopilot rule\n"

AUTOEXPAND_RULE="apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: pool-expand
spec:
  enforcement: required
  ##### conditions are the symptoms to evaluate. All conditions are AND'ed
  conditions:
    expressions:
    # pool available capacity less than the percentage
    - key: \"100 * ( px_pool_stats_available_bytes/ px_pool_stats_total_bytes)\"
      operator: Lt
      values:
        - \"${SCALE_PERCENTAGE_THRESHOLD}\"
    # pool total capacity should not exceed limit
    - key: \"px_pool_stats_total_bytes/(1024*1024*1024)\"
      operator: Lt
      values:
       - \"${MAX_CAPACITY}\"
  ##### action to perform when condition is true
  actions:
    - name: \"openstorage.io.action.storagepool/expand\"
      params:
        # resize pool by scalepercentage of current size
        scalepercentage: \"${SCALE_PERCENTAGE}\"
        # when scaling, add disks to the pool
        scaletype: \"add-disk\"
"

printf "$AUTOEXPAND_RULE" >/tmp/autoexpand.yml

printf "[INFO] Applying default autopilot rule\n"
kubectl -n $NAMESPACE apply -f /tmp/autoexpand.yml
printf "[INFO] Default autopilot rule applied\n"
