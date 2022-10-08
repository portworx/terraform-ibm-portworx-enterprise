#!/bin/bash

# Check if portworx helm charts are installed and the chart status
# helm history portworx (Find the status etc)

# if installed, then check if the version is lower than the one asked
# Check if the version is greater or not

# Wait for the pods to be restarted
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }


IMAGE_VERSION=$1
UPGRADE_REQUESTED=$2
TIMEOUT_PER_NODE=8
SLEEP_TIME=$((60 * $TIMEOUT_PER_NODE))

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
if ! JSON=$(helm history portworx -o json | jq '. | last'); then
    printf "[ERROR] Helm couldn't find Portworx Installation, will not proceed with the upgrade!! Please install portworx and then try to upgrade.\n"
    exit 1
else
    printf "$HEADER*\t\t\t\tHelm Chart Summary\t\t\t*$DIVIDER\n$JSON$DIVIDER"
fi

#Version Validation
printf "[INFO] Validating if upgrade is possible...\n"
CURRENT_VER=$(kubectl get ds portworx -n kube-system -o json | jq -r .spec.template.metadata.annotations.productVersion)
printf "$DIVIDER*\t\t\tUpgrade Version Validation\t\t\t$DIVIDER* Requested upgrade from [ $CURRENT_VER ] to [ $IMAGE_VERSION ]\t"

if [ $(version $IMAGE_VERSION) -ge $(version $CURRENT_VER) ]; then
    printf "[Passed]\t*$DIVIDER"
else
    printf "[Failed]\t*$DIVIDER"
    printf "[ERROR] Downgrade not supported. Not Upgrading\n"
    exit 1
fi


# Check if portworx ds is there, if there,  get the ds details else, exit with error
# Store the number of desired and ready pods
# Show the current pods and ds status
printf "[INFO] Validating Portworx Cluster Status...\n"
if ! ds_state=($( kubectl get -n kube-system ds portworx -o jsonpath='{.status.desiredNumberScheduled} {.status.numberReady}')); then
    printf "[ERROR] Portworx Daemon Set Not Found, will not proceed with the upgrade!! Please install portworx and then try to upgrade.\n"
    exit 1
else
    ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
    DESIRED="${ds_state[0]}"
    READY="${ds_state[1]}"
    printf "$DIVIDER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER"
fi


# If number of ready pods != desired, exit with error else, check the px cluster status
# Print the PX Cluster staus using pxctl
# If the PX Cluster is not ready, exit with error
printf "[INFO] Validating Portworx Daemonset Installation...\n"
if  [ "$READY" -ne "$DESIRED" ]; then
    printf "[ERROR] All Portworx Pods are not ready, will not proceed with the upgrade!!Please fix Portworx and then try to upgrade.\n"
    exit 1
else
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o custom-columns=":metadata.name" | awk 'END{print}')
    if ! STATUS=$(kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
        printf "[ERROR] Couldn't get portworx cluster status, will not proceed with the upgrade!!Please fix Portworx and then try to upgrade.\n"
        exit 1
    elif [ "$STATUS" == "STATUS_OK" ]; then
        ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
        printf "*\t\t\t\tPods ( $READY/$DESIRED )\t\t\t\t*\n"
        kubectl get pods -l name=portworx -n kube-system | awk 'NR>1 { print "* "$1"\t\t\t [ "$3"\t"$2"\t"$5" ]\t*"  }'
        printf "$DIVIDER*\t\t\tPortworx Status: $STATUS\t\t\t*$DIVIDER"
    else
        printf "[ERROR] Portworx Status: $STATUS, will not proceed with the upgrade!!Please fix Portworx and then try to upgrade.\n"
        exit 1
    fi
fi


# Configure kubeconfig
# Get helm binary over the internet, install helm v3.3.0
# Trigger the helm upgrade
printf "[INFO] Installing new Helm Charts...\n"
$CMD repo add community https://raw.githubusercontent.com/IBM/charts/master/repo/community
$CMD repo update
$CMD get values portworx -n default > /tmp/values.yaml
sed -i -E -e 's@PX_IMAGE=icr.io/ext/portworx/px-enterprise:.*$@PX_IMAGE=icr.io/ext/portworx/px-enterprise:'"$IMAGE_VERSION"'@g' /tmp/values.yaml
$CMD upgrade portworx community/portworx -f /tmp/values.yaml --set imageVersion=$IMAGE_VERSION

if [[ $? -eq 0 ]]; then
    echo "[INFO] Upgrade Triggered Succesfully, will monitor the pods!!"
else
    echo "[ERROR] Failed to Upgrade!!"
    exit 1
fi



# Query the Daemonset Details
# Get the desired and up-to-date pods
# Watch untill all pods are updated
printf "[INFO] Monitoring new Portworx Pods...\n"
ds_status=($(kubectl get ds portworx -n kube-system | awk 'NR>1 { print $2 " " $4 " " $5 }'))
DESIRED="${ds_status[0]}"
READY="${ds_status[1]}"
UP_TO_DATE="${ds_status[2]}"
LIMIT=$DESIRED

RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ] && [ $UP_TO_DATE -ne $DESIRED ] || [ $READY -ne $DESIRED ]; do
    ds_status=($(kubectl get ds portworx -n kube-system | awk 'NR>1 { print $1 " " $2 " " $4 " " $5 }'))
    DESIRED="${ds_status[1]}"
    READY="${ds_status[2]}"
    UP_TO_DATE="${ds_status[3]}"
    NAME="${ds_status[0]}"
    printf "$DIVIDER*\t\t\tUpgrade in Progress\t\t\t\t*$DIVIDER\tNAME\t\tDESIRED\t\tREADY\t\tUP-TO-DATE\n\t$NAME\t$DESIRED\t\t$READY\t\t\t$UP_TO_DATE$DIVIDER"
    echo "[INFO] All Portworx Pods are not upgraded, will recheck in $SLEEP_TIME secs!"
    sleep $SLEEP_TIME
    ((RETRIES++))
done

PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o custom-columns=":metadata.name" | awk 'END{print}')
if ! STATUS=$(kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
    printf "[ERROR] Couldn't get portworx cluster status, Upgrade Failed\n"
    exit 1
elif [ "$STATUS" == "STATUS_OK" ]; then
    ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
    printf "$DIVIDER*\t\t\t\tPods ( $READY/$DESIRED )\t\t\t\t*\n"
    kubectl get pods -l name=portworx -n kube-system | awk 'NR>1 { print "* "$1"\t\t\t [ "$3"\t"$2"\t"$5" ]\t*"  }'
    printf "$DIVIDER*\t\t\tPortworx Status: $STATUS\t\t\t*$DIVIDER"
    printf "[SUCCESS] Succesfully Upgraded Portworx to $IMAGE_VERSION\n"
else
    printf "[ERROR] Portworx Status: $STATUS, will not proceed with the upgrade!!Upgrade Failed\n"
    exit 1
fi
