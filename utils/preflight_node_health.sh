#!/bin/bash

echo "[INFO] Kube Config Path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
echo "Current Kube Context: $(kubectl config current-context)"

MIN_STORAGE=62500000
MIN_CPU=4
MIN_MEMORY=3906250
MIN_NODE_COUNT=3

RECOMMENDED_STORAGE=125000000
RECOMMENDED_CPU=8
RECOMMENDED_MEMORY=7812500

DIVIDER="*************************************************************************"
HEADER="\n$DIVIDER\n*\t\t\t\tCLUSTER SUMMARY\t\t\t\t*\n$DIVIDER\n"
PASS_MSG="$DIVIDER\n*     All Pre-Flight Checks for Available Nodes have Passed             *\n$DIVIDER\n"
FAIL_MSG="$DIVIDER\n*         Current Cluster doesn't meet Minimum Requirements!           *\n*   Visit https://docs.portworx.com/install-portworx/prerequisites/    *\n*                  for more information.                               *\n$DIVIDER\n"

node_num_msg="Failed"
node_health_msg="Failed"
NODES_SUMMARY=""

node_num_check=false
node_health_check=false
node_stats_check=false

####################### NUMBER OF NODES CHECK ###########################
NUM_OF_NODES=($(kubectl get nodes -o go-template='{{len .items}}'))
if [ "$NUM_OF_NODES" -ge "$MIN_NODE_COUNT" ]; then
    node_num_msg="Passed"
    ((node_num_check=true))
fi
#########################################################################


####################### NODE HEALTH CHECK ###########################
HEALTHY_NODES=($(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | awk '$2=="True" {print $1}'))
NUM_OF_HEALTHY_NODES=${#HEALTHY_NODES[@]}
if [ "$NUM_OF_HEALTHY_NODES" -eq "$NUM_OF_NODES" ]; then
    node_health_msg="Passed"
    ((node_health_check=true))
fi
NODE_HEALTH="*  Total Nodes:\t\t   $NUM_OF_NODES\t\t\t\t[$node_num_msg]\t*\n*  Healthy Nodes:\t ($NUM_OF_HEALTHY_NODES/$NUM_OF_NODES)\t\t\t\t[$node_health_msg]\t*\n$DIVIDER\n"
#########################################################################


####################### NODE STATS CHECK ###########################
NODE_STATS=($(kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}{","}{@.status.allocatable.cpu}{","}{@.status.allocatable.memory}{","}{@.status.allocatable.ephemeral-storage}{"\n"}{end}'))
checks=0
for stats in "${NODE_STATS[@]}"; do
    cpu_msg="Failed"
    mem_msg="Failed"
    storage_msg="Failed"

    IFS=","
    read -a node_details <<< "$stats"
    name=${node_details[0]}
    cpu=$((${node_details[1]/m/}/1000))
    memory=${node_details[2]/Ki/}
    storage=${node_details[3]/Ki/}

    if [ "$cpu" -ge "$MIN_CPU" ]; then
        ((checks++))
        cpu_msg="Passed"
    fi
    if [ "$memory" -ge "$MIN_MEMORY" ]; then
        ((checks++))
        mem_msg="Passed"
    fi
    if [ "$storage" -ge "$MIN_STORAGE" ]; then
        ((checks++))
        storage_msg="Passed"
    fi
    NODE_SUMMARY="*\t\t\tNode Summary ($name)\t\t\t*\n*  Available CPU:\t\t$cpu cores\t\t[$cpu_msg]\t*\n*  Available Memory:\t\t$memory Ki\t\t[$mem_msg]\t*\n*  Available Storage:\t\t$storage Ki\t\t[$storage_msg]\t*\n"
    NODES_SUMMARY="$NODES_SUMMARY$NODE_SUMMARY"
done
((checks=checks/3))
if [ "$checks" -eq "$NUM_OF_NODES" ]; then
    ((node_stats_check=true))
fi
#########################################################################


if [ $node_num_check ] && [ $node_health_check ] && [ $node_stats_check ]; then
    printf "$HEADER$NODE_HEALTH$NODES_SUMMARY$PASS_MSG"
    exit 0
else
    printf "$HEADER$NODE_HEALTH$NODES_SUMMARY$FAIL_MSG"
    exit 1
fi
