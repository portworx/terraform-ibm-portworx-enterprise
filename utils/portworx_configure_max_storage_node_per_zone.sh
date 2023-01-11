#!/bin/bash

# Check if portworx helm charts are installed and the chart status
# helm history portworx (Find the status etc)

# if installed, then configure the max storage node per zone

# Wait for the pods to be restarted
function version { printf "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

NAMESPACE=$3
PX_CLUSTER_NAME=$2
NODE_COUNT=$1
SLEEP_TIME=30

DIVIDER="\n*************************************************************************\n"
HEADER="$DIVIDER*\t\tConfigure Requested to Portworx Enterprise ${IMAGE_VERSION}\t\t*$DIVIDER"

DESIRED=0
READY=0
JSON=0

# Install helm3
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
    wget https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz -O /tmp/helm3/helm-${HELM_VER}-linux-amd64.tar.gz
    tar -xzf /tmp/helm3/helm-${HELM_VER}-linux-amd64.tar.gz -C /tmp/helm3/
    CMD="/tmp/helm3/linux-amd64/helm"
    $CMD version
fi

# Get the portworx chart namespace
CHART_NAMESPACE=$(helm ls -A | grep portworx | awk '{print $2}')
echo "[INFO] Chart namespace is $CHART_NAMESPACE"
# Get the Helm status
if ! JSON=$(helm history portworx -n ${CHART_NAMESPACE} -o json | jq '. | last'); then
    printf "[ERROR] Helm couldn't find Portworx Installation, will not proceed with the configuration!! Please install portworx and then try to configure.\n"
    exit 1
else
    printf "$HEADER*\t\t\t\tHelm Chart Summary\t\t\t*$DIVIDER\n$JSON$DIVIDER"
fi

LIMIT=20
RETRIES=0
sleep $SLEEP_TIME
while [ "$RETRIES" -le "$LIMIT" ]
do
    GREP_NS=$(kubectl get ns | grep $NAMESPACE | awk '{print $1}')
    if [ "$NAMESPACE" == "$GREP_NS" ]; then
        printf "[INFO] namespace found \n"
        break
    else
        printf "[ERROR] failed namespace not found yet\n"
        printf "[INFO] Will retry in $SLEEP_TIME secs\n"
        ((RETRIES++))
        sleep $SLEEP_TIME
    fi
done

# Check if portworx ds is there, if there,  get the ds details else, exit with error
# Store the number of desired and ready pods
# Show the current pods and ds status
printf "[INFO] Validating Portworx Cluster Status...\n"
if ! sc_state=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE}); then
    printf "[ERROR] Helm couldn't find Portworx Installation, will not proceed with configuring max storage nodes per zone!!\n"
    exit 1
else
    STATUS=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status.phase}')
    if [ "$STATUS" != "Online" ]; then
        printf "[ERROR] Portworx Storage Cluster is not Online. Cluster Status: ($STATUS), will not proceed with configuration!!\n"
        exit 1
    else
        state=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status}' | jq)
        printf "[CHECK PASSED] Portworx Storage Cluster is Online.\n$state\n"
    fi
fi



# Configure kubeconfig
# Get helm binary over the internet, install helm v3.3.0
# Trigger the helm upgrade

HELM_VALUES_FILE=/tmp/values.yaml

printf "[INFO] Installing new Helm Charts...\n"
$CMD repo add ibm-helm https://raw.githubusercontent.com/portworx/ibm-helm/master/repo/stable --force-update
$CMD repo update
$CMD get values portworx -n ${CHART_NAMESPACE} > $HELM_VALUES_FILE
ADVOPT_LINE_NO=$(grep -n 'advOpts' ${HELM_VALUES_FILE} | cut -d ':' -f1)
if [ "$ADVOPT_LINE_NO" != "" ]; then
    ADVOPT_LINE=$(grep 'advOpts' ${HELM_VALUES_FILE})
    REPLACED_LINE=${ADVOPT_LINE//,-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]],/,}
    REPLACED_LINE=${REPLACED_LINE//-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]],/}
    REPLACED_LINE=${REPLACED_LINE//,-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]]/}
    REPLACED_LINE=${REPLACED_LINE//-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]]/}

    REPLACED_LINE=${REPLACED_LINE//;-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]];/;}
    REPLACED_LINE=${REPLACED_LINE//-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]];/}
    REPLACED_LINE=${REPLACED_LINE//;-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]]/}
    REPLACED_LINE=${REPLACED_LINE// ;/ }
    REPLACED_LINE=${REPLACED_LINE//-max_storage_nodes_per_zone=[[:digit:]|[:digit:][:digit:]|[:digit:][:digit:][:digit:]]/}
    FIND_AND_REPLACE="${ADVOPT_LINE_NO}s/advOpts.*/${REPLACED_LINE}/"
    sed -i -e "${FIND_AND_REPLACE}" ${HELM_VALUES_FILE}

    ADVOPT_LENGTH=$(grep "advOpts: " ${HELM_VALUES_FILE} | awk "{print length}")
    if [ "$ADVOPT_LENGTH" == "9" ]; then
        FIND_AND_REPLACE="${ADVOPT_LINE_NO}s/.*//"
        sed -i -e "${FIND_AND_REPLACE}" ${HELM_VALUES_FILE}
    fi
else
    printf "[INFO] advOpts not found in ${HELM_VALUES_FILE}: lno_val:${ADVOPT_LINE_NO}\n"
fi
ADVOPT_LINE_NO=$(grep -n 'maxStorageNodesPerZone' ${HELM_VALUES_FILE} | cut -d ':' -f1)
if [ "$ADVOPT_LINE_NO" != "" ]; then
    FIND_AND_REPLACE="${ADVOPT_LINE_NO}s/.*//"
    sed -i -e ${FIND_AND_REPLACE} ${HELM_VALUES_FILE}
fi
echo "maxStorageNodesPerZone: ${NODE_COUNT}" >> $HELM_VALUES_FILE
printf "[INFO] maxStorageNodesPerZone value updated in ${HELM_VALUES_FILE}!!\n"
printf "[INFO] Upgrading ${HELM_VALUES_FILE} in ${CHART_NAMESPACE} namespace!!\n"
$CMD upgrade portworx ibm-helm/portworx -f ${HELM_VALUES_FILE} -n ${CHART_NAMESPACE}

if [[ $? -eq 0 ]]; then
    printf "[INFO] Upgrade Triggered Succesfully, will monitor the storage cluster!!\n"
else
    printf "[ERROR] Failed to Upgrade!!\n"
    exit 1
fi

STATUS=""
LIMIT=20
RETRIES=0
sleep $SLEEP_TIME
UPDATED_COUNT="maxStorageNodesPerZone: ${NODE_COUNT}"
while [ "$RETRIES" -le "$LIMIT" ]
do
    $CMD get values portworx -n ${CHART_NAMESPACE} > ${HELM_VALUES_FILE}
    UPDATED_VAL=$(grep maxStorageNodesPerZone ${HELM_VALUES_FILE})
    printf "compare ${UPDATED_VAL} == ${UPDATED_COUNT}\n"
    if [ "$UPDATED_VAL" == "$UPDATED_COUNT" ]; then
        printf "[INFO] max storage node value updated\n"
        break
    else
        printf "[ERROR] failed to check maxStorageNodesPerZone value\n"
    fi
    printf "[INFO] Waiting for Portworx Storage Cluster. (Retry in $SLEEP_TIME secs)\n"
    ((RETRIES++))
    sleep $SLEEP_TIME
done

if [ "$RETRIES" -gt "$LIMIT" ]; then
    printf "[ERROR] All Retries Exhausted!\n"
    exit 1
fi

printf "[INFO] max storage node configuration completed\n"
exit 0
