#!/bin/bash

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

DESIRED=$(kubectl get ds/portworx -n kube-system -o json | jq .status.desiredNumberScheduled)
READY=0

LIMIT=20
SLEEP_TIME=30
i=0

while [ $i -lt $LIMIT ] && [ $DESIRED -ne $READY ]; do
    READY=$(kubectl get ds/portworx -n kube-system -o json | jq .status.numberReady)

    if [ $DESIRED -eq $READY ]; then
        echo "(Attempt $i of $LIMIT) Portworx pods: Desired $DESIRED, Ready $READY"
    else
        echo "(Attempt $i of $LIMIT) Portworx pods: Desired $DESIRED, Ready $READY, sleeping $SLEEP_TIME"
        sleep $SLEEP_TIME
    fi

    i=$(( $i + 1 ))
done
