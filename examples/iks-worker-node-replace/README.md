# Getting Started

This guide is intended to provide an example on how to gracefully replace a worker node with Portworx Enterprise already installed using Cloud Drives in an existing IKS VPC Gen 2 Cluster.
You can use this example to replace all the existing worker nodes or just some of them.

> **NOTE:** This example is tested on **VPC Gen2 IKS Clusters** with Portworx Enterprise provisioned with **Cloud Drives** only.

## Pre-requisites

- Terraform >= 0.13
- Already Provisioned IKS Cluster with Portworx Enterprise Installed using Cloud Drives.

## Setting Up Environment

In this example we'll specifically walk you through the process of gracefully replacing a worker node with Portworx Enterprise already installed in an existing IKS VPC Gen 2 Cluster.

> Clone this Repo and `cd` into the `examples/iks-worker-node-replace`, and now you can issue the following commands to proceed.

### Required Data/Values

These are following data/values required that shall be passed to the terraform scripts as variables.

- IKS Cluster name
- IBM Cloud API Key
- The Resource Group name where the Cluster exists
- IBM Region where Cluter is provisioned
- List of ID's of all worker nodes which are to be replaced. **_(example ID: `kube-cd74oo9w08o0vh5e0850-superikscluster-default-000005df`)_**

### Creating Variables

Before you run the `terraform` scripts, you can use `terraform.tfvars` or `Environment Variables` or `-var` or `-var-file` in supplement with the examples. Refer to [Terraform Documentation](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables)

We shall use `terraform.tfvars` in these examples.

> Example `terraform.tfvars` **(You can find a `terraform.tfvars.sample` file in each example directory, rename the file and set the correct values)**

```terraform
resource_group   = "your_resource_group_name"
region           = "region_name"
iks_cluster_name = "your_iks_cluster_name"
worker_ids       = ["worker_id_1", "worker_id_2", "worker_id_3"]
replace_all_workers = false
```

> NOTE: If you want to **replace all** of the existing worker nodes, toggle the value of `replace_all_workers` to `true` and remove the `worker_ids` variable

Create the above file with name `terraform.tfvars`
Check the `examples/variables.tf` to understand what are all the variables required

## Setting up Credentials

```sh
export IC_API_KEY="secret_ibm_cloud_key"
```

## Replace the Worker Nodes

```sh
terraform init
terraform plan -out tf.plan
terraform apply tf.plan
terraform output
```
