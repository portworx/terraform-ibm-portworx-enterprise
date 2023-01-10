#!/bin/bash

NAMESPACE=$2
DELETE_STRATEGY=$1
# Current context
echo "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

echo '**********************************************************************'
echo '            Uninstalling Portworx Enterprise Installation'
echo '**********************************************************************'

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

$CMD repo add ibm-helm-portworx https://raw.githubusercontent.com/portworx/ibm-helm/master/repo/stable
$CMD repo update
$CMD upgrade portworx ibm-helm-portworx/portworx --reuse-values --set deleteStrategy.type=$DELETE_STRATEGY -n $NAMESPACE > /dev/null


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
