#!/bin/bash
# TODO: Parameterise $NAMESPACE
NAMESPACE="kube-system"
PX_CLUSTER_NAME=$2

STATUS=""
SLEEP_TIME=30
LIMIT=10
RETRIES=0
sleep 90

while [ "$RETRIES" -le "$LIMIT" ]
do
    STATUS=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.items[*].status.phase}')
    if [ "$STATUS" == "Online" ]; then
        CLUSTER_ID=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o jsonpath='{.items[*].status.clusterUid}')
        printf "[SUCCESS] Portworx Storage Cluster is Online. Cluster ID: ($CLUSTER_ID)\n"
        break
    fi
    printf "[INFO] Portworx Storage Cluster Status: [ $STATUS ]\n"
    printf "[INFO] Waiting for Portworx Storage Cluster. (Retry in $SLEEP_TIME secs)\n"
    ((RETRIES++))
    sleep $SLEEP_TIME
done

if [ "$RETRIES" -gt "$LIMIT" ]; then
    printf "[ERROR] All Retries Exhausted!\n"
    exit 1
fi