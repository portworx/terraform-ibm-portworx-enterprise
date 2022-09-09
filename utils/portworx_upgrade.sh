#!/bin/bash
IMAGE_VERSION=$1
UPGRADE_REQUESTED=$2

if $UPGRADE_REQUESTED
then
    echo "Portworx-Enterprise Upgrade Requested!!"
else
    echo "No Upgrade Requested!!"
    exit 0
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


$CMD repo add community https://raw.githubusercontent.com/IBM/charts/master/repo/community
$CMD repo update
$CMD get values portworx -n default > /tmp/values.yaml
sed -i -E -e 's@PX_IMAGE=icr.io/ext/portworx/px-enterprise:.*$@PX_IMAGE=icr.io/ext/portworx/px-enterprise:'"$IMAGE_VERSION"'@g' /tmp/values.yaml
$CMD upgrade portworx community/portworx -f /tmp/values.yaml --set imageVersion=$IMAGE_VERSION --wait --timeout 10m0s

#TODO: Fail if pods are not up, will have to use kubectl get status and all