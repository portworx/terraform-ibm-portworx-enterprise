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

### Run the `terraform` scripts
```sh
cd roks-<example_name>
terragrunt init -upgrade
terragrunt plan -out tf.plan
terragrunt apply tf.plan
```