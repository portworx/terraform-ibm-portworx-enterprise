#!/bin/bash

NAMESPACE="kube-system"
DELETE_STRATEGY=$1
# Current context
echo "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

echo '**********************************************************************'
echo '            Uninstalling Portworx Enterprise Installation'
echo '**********************************************************************'

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

$CMD repo add ibm-helm https://raw.githubusercontent.com/portworx/ibm-helm/master/repo/stable
$CMD repo update
$CMD upgrade portworx ibm-helm/portworx --reuse-values --set deleteStrategy.type=$DELETE_STRATEGY -n $NAMESPACE > /dev/null


echo "[INFO] Listing releases ... "
$CMD ls -A
echo "[INFO] Cleaning up portworx release..."
$CMD delete portworx -n $NAMESPACE
if [[ $? -eq 0 ]]; then
    echo "[INFO] Successfully Un-Installed!!"
else
    echo "[ERROR] Failed to Uninstall!!!"
    exit 1
fi
