#!/bin/bash
IMAGE_VERSION=$1
UPGRADE_REQUESTED=$2

DIVIDER="\n*************************************************************************\n"
HEADER="$DIVIDER*\t\tUpgrade Requested to Portworx Enterprise ${IMAGE_VERSION}\t\t*$DIVIDER"

DESIRED=0
READY=0

if $UPGRADE_REQUESTED
then
    printf $HEADER
else
    printf "No Upgrade Requested!!\n"
    exit 0
fi

if ! ds_state=($( kubectl get -n kube-system ds portworx -o jsonpath='{.status.desiredNumberScheduled} {.status.numberReady}')); then
    printf "[ERROR] Portworx Daemon Set Not Found, will not proceed with the upgrade!! Please install portworx and then try to upgrade.\n"
    exit 1
else
    ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
    DESIRED="${ds_state[0]}"
    READY="${ds_state[1]}"
    printf "$HEADER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER*\t\t\t\tPods ( $READY/$DESIRED )\t\t\t\t*$DIVIDER"
fi

if  [ "$READY" -ne "$DESIRED" ]; then
    printf "[ERROR] All Portworx Pods are not ready, will not proceed with the upgrade!!Please fix Portworx and then try to upgrade.\n"
    exit 1
else
    echo "[INFO] Getting Portworx Installation Status..."
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o custom-columns=":metadata.name" | awk 'END{print}')
    if ! STATUS=$(kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
        echo "[ERROR] Couldn't get portworx cluster status."
        exit 1
    elif [ "$STATUS" == "STATUS_OK" ]; then
        ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
        printf "$HEADER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER*\t\t\t\tPods ( $READY/$DESIRED )\t\t\t\t*\n"
        kubectl get pods -l name=portworx -n kube-system | awk 'NR>1 { print "* "$1"\t\t\t [ "$3"\t"$2"\t"$5" ]\t*"  }'
        printf "$DIVIDER*\t\t\tPortworx Status: $STATUS\t\t\t*$DIVIDER"
    else
        echo "[INFO] Portworx Status: $STATUS"
        exit 1
    fi
fi


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

$CMD history portworx
$CMD repo add community https://raw.githubusercontent.com/IBM/charts/master/repo/community
$CMD repo update
$CMD get values portworx -n default > /tmp/values.yaml
sed -i -E -e 's@PX_IMAGE=icr.io/ext/portworx/px-enterprise:.*$@PX_IMAGE=icr.io/ext/portworx/px-enterprise:'"$IMAGE_VERSION"'@g' /tmp/values.yaml
$CMD upgrade portworx community/portworx -f /tmp/values.yaml --set imageVersion=$IMAGE_VERSION --wait --timeout 5h0m0s
if [[ $? -eq 0 ]]; then
    echo "[INFO] Successfully Upgraded!!"
else
    echo "[ERROR] Failed to Upgrade!!"
    exit 1
fi
