#!/bin/bash
SLEEP_TIME=10
LIMIT=10
DIVIDER="\n*************************************************************************\n"
HEADER="$DIVIDER*\t\t\tPortworx Resources Status\t\t\t*$DIVIDER"

echo "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
echo "Current Kube Context: $(kubectl config current-context)"
DESIRED=0
READY=0

RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  if ! ds_state=($( kubectl get -n kube-system ds/portworx -o jsonpath='{.status.desiredNumberScheduled} {.status.numberReady}')); then
    echo "[WARN] Portworx Daemon Set Not Found, will retry in $SLEEP_TIME secs!"
    sleep $SLEEP_TIME
    ((RETRIES++))
  else
    ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
    printf "$HEADER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER"
    DESIRED="${ds_state[0]}"
    READY="${ds_state[1]}"
    break
  fi
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
  echo "[ERROR] All Retries Exhausted!"
  exit 1
fi

RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ] && [ "$READY" -lt "$DESIRED" ]; do
  if ! ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2)); then
    echo "[WARN] Portworx Pods Status Not Found, will retry in $SLEEP_TIME secs!"
    ((RETRIES++))
  else
    printf "$HEADER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER"
    kubectl get pods -l name=portworx -n kube-system | awk 'NR>1 { print "* "$1"\t\t\t [ "$3"\t"$2"\t"$5" ]\t*"  }'
    printf $DIVIDER
    echo "[INFO] All Portworx Pods are not ready, will recheck in $SLEEP_TIME secs!"
  fi
  sleep $SLEEP_TIME
done
if [ "$RETRIES" -gt "$LIMIT" ]; then
  echo "[ERROR] All Retries Exhausted!"
  exit 1
fi


RETRIES=0
while [ "$RETRIES" -le "$LIMIT" ]; do
  echo "[INFO] Getting Portworx Installation Status..."
  PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o custom-columns=":metadata.name" | awk 'END{print}')
  if ! STATUS=$(kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status --json | jq -r '.status'); then
    echo "[WARN] Portworx Status Not Found, will retry in $SLEEP_TIME secs!"
    (( RETRIES++ ))
    sleep $SLEEP_TIME
  elif [ "$STATUS" == "STATUS_OK" ]; then
    ds_status=($(kubectl describe ds portworx -n kube-system | grep "Pods Status" | cut -d ":" -f 2))
    printf "$HEADER*\t\t\t\tDaemonset Status\t\t\t*\n* portworx\t[ ${ds_status[*]} ]\t*$DIVIDER"
    kubectl get pods -l name=portworx -n kube-system | awk 'NR>1 { print "* "$1"\t\t\t [ "$3"\t"$2"\t"$5" ]\t*"  }'
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