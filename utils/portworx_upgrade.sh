#!/bin/bash

# Check if portworx helm charts are installed and the chart status
# helm history portworx (Find the status etc)

# if installed, then check if the version is lower than the one asked
# Check if the version is greater or not

# Wait for the pods to be restarted
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# TODO: Parameterise $NAMESPACE
NAMESPACE="kube-system"
PX_CLUSTER_NAME=$3
IMAGE_VERSION=$1
UPGRADE_REQUESTED=$2
SLEEP_TIME=30

DIVIDER="\n*************************************************************************\n"
HEADER="$DIVIDER*\t\tUpgrade Requested to Portworx Enterprise ${IMAGE_VERSION}\t\t*$DIVIDER"

DESIRED=0
READY=0
JSON=0
if $UPGRADE_REQUESTED
then
    printf "Upgrade Requested, Setting up Environment!!\n"
else
    printf "No Upgrade Requested!!\n"
    exit 0
fi

# Install helm3
# Check the Helm Chart Summary
echo "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

CMD="helm"
VERSION=$($CMD version | grep v3)
if [ "$VERSION" == "" ]; then
    echo "[WARN] Helm v3 is not installed, migrating to v3.3.0..."
    mkdir /tmp/helm3
    wget https://get.helm.sh/helm-v3.3.0-linux-amd64.tar.gz -O /tmp/helm3/helm-v3.3.0-linux-amd64.tar.gz
    tar -xzf /tmp/helm3/helm-v3.3.0-linux-amd64.tar.gz -C /tmp/helm3/
    CMD="/tmp/helm3/linux-amd64/helm"
    $CMD version
fi
# Get the Helm status
if ! JSON=$(helm history portworx -n ${NAMESPACE} -o json | jq '. | last'); then
    printf "[ERROR] Helm couldn't find Portworx Installation, will not proceed with the upgrade!! Please install portworx and then try to upgrade.\n"
    exit 1
else
    printf "$HEADER*\t\t\t\tHelm Chart Summary\t\t\t*$DIVIDER\n$JSON$DIVIDER"
fi

#Version Validation
printf "[INFO] Validating if upgrade is possible...\n"
CURRENT_VER=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath={.status.version})
printf "$DIVIDER*\t\t\tUpgrade Version Validation\t\t\t$DIVIDER* Requested upgrade from [ $CURRENT_VER ] to [ $IMAGE_VERSION ]\t"

if [[ ! -z "$CURRENT_VER" ]] && [ $(version $IMAGE_VERSION) -ge $(version $CURRENT_VER) ]; then
    printf "[CHECK PASSED]\t*$DIVIDER"
else
    printf "[CHECK FAILED]\t*$DIVIDER"
    printf "[ERROR] Downgrade not supported. Not Upgrading\n"
    exit 1
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
    if [ "$STATUS" != "Online" ]; then
        printf "[ERROR] Portworx Storage Cluster is not Online. Cluster Status: ($STATUS), will not proceed with the upgrade!!\n"
        exit 1
    else
        state=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status}' | jq)
        printf "[CHECK PASSED] Portworx Storage Cluster is Online.\n$state\n"
    fi
fi



# Configure kubeconfig
# Get helm binary over the internet, install helm v3.3.0
# Trigger the helm upgrade
printf "[INFO] Installing new Helm Charts...\n"
$CMD repo add ibm-helm https://raw.githubusercontent.com/portworx/ibm-helm/master/repo/stable
$CMD repo update
$CMD get values portworx -n ${NAMESPACE} > /tmp/values.yaml
sed -i -E -e 's@PX_IMAGE=icr.io/ext/portworx/px-enterprise:.*$@PX_IMAGE=icr.io/ext/portworx/px-enterprise:'"$IMAGE_VERSION"'@g' /tmp/values.yaml
$CMD upgrade portworx ibm-helm/portworx -f /tmp/values.yaml --set imageVersion=$IMAGE_VERSION -n ${NAMESPACE}

if [[ $? -eq 0 ]]; then
    echo "[INFO] Upgrade Triggered Succesfully, will monitor the storage cluster!!"
else
    echo "[ERROR] Failed to Upgrade!!"
    exit 1
fi

STATUS=""
LIMIT=20
RETRIES=0
sleep $SLEEP_TIME

while [ "$RETRIES" -le "$LIMIT" ]
do
    STATUS=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status.phase}')
    CLUSTER_VERSION=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status.version}')
    if [ "$STATUS" == "Online" ] && [ "$CLUSTER_VERSION" == "$IMAGE_VERSION" ]; then
        S=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.status}' | jq)
        printf "[SUCCESS] Portworx Storage Cluster is Online.\n$S$DIVIDER"
        break
    fi
    printf "[INFO] Portworx Storage Cluster Status: [ $STATUS ]\n"
    printf "[INFO] Portworx Storage Cluster Version: [ $CLUSTER_VERSION ]\n"
    printf "[INFO] Waiting for Portworx Storage Cluster. (Retry in $SLEEP_TIME secs)\n"
    ((RETRIES++))
    sleep $SLEEP_TIME
done

if [ "$RETRIES" -gt "$LIMIT" ]; then
    printf "[ERROR] All Retries Exhausted!\n"
    exit 1
fi


RETRIES=0
DESIRED=$(kubectl get pods -l name=portworx -n ${NAMESPACE} --no-headers | wc -l)
READY=0
LIMIT=30
while [ "$RETRIES" -le "$LIMIT" ]; do
    printf "[INFO] Getting Portworx Storage Class Pods Status..\n"
    READY=$(kubectl get pods -l name=portworx -n ${NAMESPACE} -o custom-columns=":metadata.name,:spec.containers[0].image,:status.containerStatuses[0].ready" | awk -v IMAGE_VERSION="${IMAGE_VERSION}"  '{split($2,a,":")} a[2] == IMAGE_VERSION && $3 == "true"  { print $0 }' | wc -l)
    S=$(kubectl get pods -l name=portworx -n ${NAMESPACE} -o custom-columns=":metadata.name,:status.phase,:spec.containers[0].image")
    printf "$DIVIDER*\t\t\t\tPods (${READY// /}/${DESIRED// /})\t\t\t\t*$DIVIDER$S$DIVIDER"
    if [ "${READY// /}" -eq "${DESIRED// /}" ]; then
        printf "[SUCCESS] All Portworx Pods have been upgraded to version: ${IMAGE_VERSION}"
        break
    fi
    ((RETRIES++))
    sleep 300
    printf "[INFO] Waiting for Portworx Storage Cluster. (Retry in 300 secs)\n"
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
    echo "[ERROR] All Retries Exhausted!"
    exit 1
fi


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
    echo "[INFO] Getting Portworx Installation Status..."
    PX_POD=$(kubectl get pods -l name=portworx -n ${NAMESPACE} -o custom-columns=":metadata.name" | awk 'END{print}')
    if ! STATUS=$(kubectl exec $PX_POD -n ${NAMESPACE} -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
        echo "[WARN] Portworx Status Not Found, will retry in $SLEEP_TIME secs!"
        (( RETRIES++ ))
        sleep $SLEEP_TIME
    elif [ "$STATUS" == "STATUS_OK" ]; then
        printf "$DIVIDER*\t\t\tPortworx Status: $STATUS\t\t\t*$DIVIDER"
        echo "[INFO] Successful Upgrade!!"
        break
    else
        echo "[INFO] Portworx Status: $STATUS"
        sleep $SLEEP_TIME
    fi
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
    echo "[ERROR] All Retries Exhausted!"
    exit 1
fi