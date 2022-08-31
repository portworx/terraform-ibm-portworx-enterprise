#!/bin/bash

###########################################################
# For more information on Delete/Wipe Portworx cluster configuration, see
# https://docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/uninstall/
###########################################################

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

echo "Kube version: $KUBE_VERSION"
export CLUSTER_VERSION=$KUBE_VERSION
echo "Cluster version: $CLUSTER_VERSION"

CMD="helm"
VERSION=$($CMD version | grep v3)
if [ "$VERSION" == "" ]; then
    echo "Helm v3 is not installed, migrating from 2 to 3"

    mkdir /tmp/helm3
    wget https://get.helm.sh/helm-v3.3.0-linux-amd64.tar.gz -O /tmp/helm3/helm-v3.3.0-linux-amd64.tar.gz
    tar -xzf /tmp/helm3/helm-v3.3.0-linux-amd64.tar.gz -C /tmp/helm3/
    CMD="/tmp/helm3/linux-amd64/helm"

    $CMD version
fi

echo "Uninstalling portworx from cluster ..."
sh ./px-wipe.sh -f
echo "Listing releases ... "
$CMD ls --namespace default --all

echo "Deleting portworx release ..."
$CMD delete portworx
