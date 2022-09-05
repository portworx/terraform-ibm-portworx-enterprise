#!/bin/bash
echo '**********************************************************************'
echo '            Validating Portworx Enterprise Installation'
echo '**********************************************************************'
SLEEP_TIME=5
LIMIT=10
echo '[INFO] Trying to read Portworx Daemon Set Status...'


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  # Check if pods are ready
  if ! DESIRED=$(kubectl get -n kube-system ds/portworx -o jsonpath='{.status.desiredNumberScheduled}'); then
    echo "[WARN] Portworx Daemon Set Status Not Found, will retry in $SLEEP_TIME secs!"
    sleep $SLEEP_TIME
    ((RETRIES++))
  else
    echo '[INFO] Found Portworx Daemon Set Status...'
    break
  fi
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
  echo "[ERROR] All Retries Exhausted!"
  exit 0
fi


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  if ! READY=$(kubectl get -n kube-system ds/portworx -o jsonpath='{.status.numberReady}'); then
    echo "[WARN] Portworx Daemon Set Status Not Found, will retry in $SLEEP_TIME secs!"
    (( RETRIES++ ))
  elif [ "$DESIRED" -eq "$READY" ]; then
    echo "[INFO] ($READY/$DESIRED) Pods Ready..."
    break
  elif [ "$DESIRED" -gt "$READY" ]; then
    echo "[INFO] ($READY/$DESIRED) Pods Ready, waiting for pods to come up..."
    sleep $SLEEP_TIME
  fi
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
  echo "[ERROR] All Retries Exhausted!"
  exit 0
fi


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  # Check if pods are ready
  if ! PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}'); then
    echo "[WARN] Portworx Daemon Pod Status Not Found, will retry in $SLEEP_TIME secs!"
    sleep $SLEEP_TIME
    (( RETRIES++ ))
  else
    echo '[INFO] Found Portworx Daemon Pod...'
    break
  fi
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
  echo "[ERROR] All Retries Exhausted!"
  exit 0
fi


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  echo "[INFO] Getting Portworx Installation Status..."
  if ! STATUS=$(kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
    echo "[WARN] Portworx Status Not Found, will retry in $SLEEP_TIME secs!"
    (( RETRIES++ ))
  elif [ "$STATUS" == "STATUS_OK" ]; then
    echo "[INFO] Portworx Status: $STATUS"
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
#TODO: Fix the code so that when retries exhaust, terraform shows error