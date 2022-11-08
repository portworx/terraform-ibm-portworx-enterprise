#!/bin/bash
echo '**********************************************************************'
echo '            Uninstalling Portworx Enterprise Installation'
echo '**********************************************************************'
# Current context
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

echo "[INFO] Uninstalling Portworx from Cluster..."
wget "https://install.portworx.com/px-wipe" -O /tmp/px-wipe
echo "[INFO] Trying to wipe entire Portworx Cluster.."
bash /tmp/px-wipe -f
echo "[INFO] Listing releases ... "
$CMD ls --namespace default --all
echo "[INFO] Cleaning up portworx release..."
$CMD delete portworx
if [[ $? -eq 0 ]]; then
    echo "[INFO] Successfully Un-Installed!!"
else
    echo "[ERROR] Failed to Uninstall!!!"
fi

echo "[INFO] attempt to cleanup portworx-operator and portworx-hook clusterrole"
kubectl delete clusterrole/portworx-hook clusterrole/portworx-operator
echo "[INFO] attempt to cleanup portworx-operator and portworx-hook clusterrolebinding"
kubectl delete clusterrolebinding/portworx-hook clusterrolebinding/portworx-operator
