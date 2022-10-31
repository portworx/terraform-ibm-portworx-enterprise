# Getting Started

This guide is intended to provide a quick start to users who want to manage Portworx Enterprise on their existing IKS Clusters using Terraform.

## Pre-requisites

- Terraform >= 0.13
- Already Provisioned IKS Cluster
- `ibmcloud ks` cli plugin is not needed by the Terraform script but is needed to get the kubeconfig. e.g. `ibmcloud ks cluster config --admin --cluster <cluster_name | cluster_id>`
- `kubectl` installed and pointed to the correct IKS Cluster
- `jq`, `curl`, `wget` installed on the local machine

## Available examples

There are 4 examples which includes:

- IKS Cluster created using Classic Infra **[iks-classic-infra](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-classic-infra)**
- IKS Cluster created using VPC Gen 2 _(Block Volumes already attached to the k8s worker nodes by the user)_ **[iks-with-attached-drives](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-attached-drives)**
- IKS Cluster created using VPC Gen 2 using Cloud Drives **[iks-with-cloud-drives](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-cloud-drives)**
- Worker Node Replacement on IKS Cluster created using VPC Gen 2 using Cloud Drives **[iks-worker-node-replace](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-worker-node-replace)**
