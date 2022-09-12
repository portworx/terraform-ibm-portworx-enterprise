# Running the examples

## Pre-requisites
- Terraform >= 0.13
- Already Provisioned IKS Cluster
- `ibmcloud` cli is not needed by the Terraform script but is needed to get the kubeconfig. e.g. `ibmcloud ks cluster config --admin --cluster <cluster_name | cluster_id>`
- `kubectl` installed and pointed to the correct IKS Cluster
- `jq` installed on the local machine


## Steps
### Available examples
There are 3 examples which includes:
- IKS Cluster created using Classic Infra **[iks-classic-infra]**
- IKS Cluster created using VPC Gen 2 *(Block Volumes already attached to the nodes by customer)* **[iks-with-attached-drives]**
- IKS Cluster created using VPC Gen 2 using Cloud Drives **[iks-with-cloud-drives]**

### Creating Variables
Before you run the `terraform` scripts, you can use `terraform.tfvars` or `Environment Variables` or `-var` or `-var-file` in supplement with the examples. Refer to [Terraform Documentation](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables)

We shall use `terraform.tfvars` in these examples.

>Example `terraform.tfvars`
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
export IC_API_KEY="secret_ibm_cloud_key"
ibmcloud ks cluster config --admin --cluster <cluster_name | cluster_id>
cd iks-<example_name>
terraform init
terraform plan -out tf.plan
terraform apply tf.plan
```
