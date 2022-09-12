# Running the examples

## Pre-requisites
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) and Terraform >= 0.13
- Already Provisioned IKS Cluster
- `kubectl` installed and pointed to the correct IKS Cluster


## Steps
### Available examples
There are 6 examples which includes:
- ROKS Cluster created using Classic Infra **[roks-classic-infra]**
- ROKS Cluster created using VPC Gen 2 (Block Volumes already attached to the nodes by customer) **[roks-with-attached-drives]**
- ROKS Cluster created using VPC Gen 2 using Cloud Drives **[roks-with-cloud-drives]**
- Vanilla Cluster created using Classic Infra **[vanilla-classic-infra]**
- Vanilla Cluster created using VPC Gen 2 (Block Volumes already attached to the nodes by customer) **[vanilla-with-attached-drives]**
- Vanilla Cluster created using VPC Gen 2 using Cloud Drives **[vanilla-with-cloud-drives]**

### Creating Variables
Before you run the `terraform` scripts, you can use `terraform.tfvars` or `Environment Variables` or `-var` or `-var-file` in supplement with the examples. Refer to [Terraform Documentation](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables)

We shall use `terraform.tfvars` in these examples.

>Example `terraform.tfvars` *(place it inside the examples/`required-example-directory`)*
```terraform
iks_cluster_name="your_cluster_name"
resource_group="your_resource_group_name"
ibmcloud_api_key="secret_ibm_cloud_key"
use_cloud_drives=true
portworx_version="2.11.0"
```
Check the `examples/variables.tf` to understand what are the variables required


### Run the `terraform` scripts
```sh
export export IC_API_KEY="ibm_api_key"
cd roks-<example_name>
terragrunt init -upgrade
terragrunt plan -out tf.plan
terragrunt apply tf.plan
```
