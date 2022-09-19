# Getting Started
This guide is intended to provide a quick start to users who want to install Portworx Enterprise on their existing IKS Clusters.
## Pre-requisites
- Terraform >= 0.13
- Already Provisioned IKS Cluster
- `ibmcloud ks` cli plugin is not needed by the Terraform script but is needed to get the kubeconfig. e.g. `ibmcloud ks cluster config --admin --cluster <cluster_name | cluster_id>`
- `kubectl` installed and pointed to the correct IKS Cluster
- `jq`, `curl`, `wget` installed on the local machine


## Available examples
There are 3 examples which includes:
- IKS Cluster created using Classic Infra **[iks-classic-infra]**
- IKS Cluster created using VPC Gen 2 *(Block Volumes already attached to the k8s worker nodes by the user)* **[iks-with-attached-drives]**
- IKS Cluster created using VPC Gen 2 using Cloud Drives **[iks-with-cloud-drives]**

## Setting Up Environment
In this example we'll specifically walk you through the process of installing Portworx Enterprise on IKS using Cloud Drives, the same steps can be performed for the other examples with changes to the `terraform.tfvars` file.
>Clone this Repo and `cd` into the `examples/iks-with-cloud-drives`, and now you can issue the following commands to proceed.

### Required Data/Values
These are following data/values required that shall be passed to the terraform module as variables.
- IKS Cluster name
- IBM Cloud API Key
- The Resource Group name where the Cluster exists, **the Portworx Enterprise Service Instance will be created in the same Resource Group.**

### Creating Variables
Before you run the `terraform` scripts, you can use `terraform.tfvars` or `Environment Variables` or `-var` or `-var-file` in supplement with the examples. Refer to [Terraform Documentation](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables)

We shall use `terraform.tfvars` in these examples.

>Example `terraform.tfvars`
>**(You can find a `terraform.tfvars.sample` file in each example directory, rename the file and set the correct values)**
```terraform
iks_cluster_name="your_cluster_name"
resource_group="your_resource_group_name"
ibmcloud_api_key="secret_ibm_cloud_key"
use_cloud_drives=true
```
Create the above file with name `terraform.tfvars`

Check the `examples/variables.tf` to understand what are the variables required

## Setting up Credentials
```sh
export IC_API_KEY="secret_ibm_cloud_key"
ibmcloud ks cluster config --admin --cluster <cluster_name | cluster_id>
cd iks-<example_name>
```

## Installation
```sh
terraform init
terraform plan -out tf.plan
terraform apply tf.plan
terraform output
```

## Upgrade
- Add the following variables to the existing `terraform.tfvars`. Replace `<newer_version>` with the version of your choice.
```terraform
iks_cluster_name = "your_cluster_name"
resource_group   = "your_resource_group_name"
ibmcloud_api_key = "secret_ibm_cloud_key"
portworx_version = "<newer_version>"
upgrade_portworx = true
```
- Plan and Apply the changes
```sh
terraform plan -out tf.plan
terraform apply tf.plan
terraform output
```

## Uninstallation
```sh
terraform destroy
```