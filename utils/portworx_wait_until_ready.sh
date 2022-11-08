#!/bin/bash
NAMESPACE=$2
PX_CLUSTER_NAME=$1

DIVIDER="\n*************************************************************************\n"
STATUS=""
SLEEP_TIME=30
LIMIT=15
RETRIES=0
sleep 90

while [ "$RETRIES" -le "$LIMIT" ]
do
    STATUS=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o yaml | grep phase | cut -d ":" -f2)
    if [ "${STATUS// /}" == "Online" ]; then
        CLUSTER_ID=$(kubectl get storagecluster ${PX_CLUSTER_NAME} -n ${NAMESPACE} -o yaml | grep clusterUid | cut -d ":" -f2)
        printf "[SUCCESS] Portworx Storage Cluster is Online. Cluster ID: (${CLUSTER_ID// /})\n"
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


RETRIES=0
DESIRED=$(kubectl get pods -l name=portworx -n ${NAMESPACE} --no-headers | wc -l)
READY=0
while [ "$RETRIES" -le "$LIMIT" ]; do
    READY=$(kubectl get pods -l name=portworx -n ${NAMESPACE} -o custom-columns=":metadata.name,:status.phase,:status.containerStatuses[0].ready" | awk '$3 == "true"  { print $0 }' | wc -l)
    POD_STATUS=$(kubectl get pods -l name=portworx -n ${NAMESPACE} -o custom-columns=":metadata.name,:status.phase")
    printf "$DIVIDER*\t\t\t\tPods (${READY// /}/${DESIRED// /})\t\t\t\t*$DIVIDER$POD_STATUS$DIVIDER"
    if [ "${READY// /}" -eq "${DESIRED// /}" ]; then
        printf "[SUCCESS] All Portworx Pods are Ready.\n"
        break
    fi
    ((RETRIES++))
    sleep $SLEEP_TIME
    printf "[INFO] Getting Portworx Storage Class Pods Status... (Retry in $SLEEP_TIME secs)\n"
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
    echo "[INFO] Successful Installation!!"
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
