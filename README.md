# IBM Cloud Portworx Enterprise Module
IBM Cloud provides a way to provision Portworx Enterprise on IKS Cluster through IBM Catalog. This repo hosts the terraform module which can be used in conjuction with any existing terraform scripts to provision Portworx Enterprise on IKS.

## Usage

You can include the below module defination in a `.tf` file to deploy Portworx Enterprise with the default values.

> Please take a look at the defaults value in the **Inputs** Section below

```terraform
module "portworx-enterprise" {
  source                    = "github.com/portworx/terraform-ibm-portworx-enterprise.git"
  region                    = "us-east"
  cluster_name              = "my-iks-cluster"
  resource_group            = "my-resource-group"
}
```
## Features

- Declarative Installation/Uninstallation
- Seamless Upgrades
- Support for Cloud Drives & Raw Mounted Volumes
- Easy Integration with existing Terraform Scripts
- Built-in Preflight Checks

## Getting Started

> Please refer to [this Getting Started Guide](https://github.com/portworx/terraform-ibm-portworx-enterprise/blob/main/examples/README.md) as a quickstart to install Portworx Enterprise on an IKS using Cloud Drives.
> This guide is intentetd to walk you through the steps needed to set up an environment to be able to perform the terraform deployment on IBM Cloud.

## Examples

We have compiled a directory full of helpful examples which can be a good starting points to understand and demonstrate the features and capabilities of this module.

- [Installation on IKS Cluster created using Classic Infra](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-classic-infra)
- [Installation on IKS Cluster created using VPC Gen 2 with Cloud Drives](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-attached-drives)
- [Installation on IKS Cluster created using VPC Gen 2 with Block Volumes already attached to worker nodes](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-cloud-drives)

## Requirements

The following are requirements needed to be installed on the host machine where the terraform commands will be issued.
We are using a couple of bash scripts, for validation and checks, hence we will need libraries like `wget`, `curl` and `jq`.

Refer to this table below for more details.

| Name  | Version |
| ------------- | ------------- |
| terraform  | 0.13 and above |
| kubectl  | 1.22.0 and above |
| jq  | 1.6 and above |
| curl  | 7.79.1 and above |
| wget  | 1.21.3 and above |
| tar  | 3.5.1 and above |
| ibmcloud  | 2.10.0 and above |

## Providers

The following are the providers which are used by our modules, inorder to manage resources on IBM Cloud

| Name  | Version |
| ------------- | ------------- |
| ibm-cloud/ibm  | v1.45.0 and above |
| hashicorp/random  | 3.4.3 and above |
| hashicorp/null  | 3.1.1 and above |
## Resources

These are the **resources**/**data sources** that are created to manage the resources that this module manages.

| Name | Type |
|------|------|
| [ibm_resource_instance.portworx](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [null_resource.portworx_destroy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.portworx_upgrade](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.preflight_checks](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_uuid.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [ibm_container_cluster.cluster_classic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/container_cluster) | data source |
| [ibm_container_cluster_worker.worker_classic](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/container_cluster_worker) | data source |
| [ibm_container_vpc_cluster.cluster](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/container_vpc_cluster) | data source |
| [ibm_container_vpc_cluster_worker.worker](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/container_vpc_cluster_worker) | data source |
| [ibm_resource_group.group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

## Inputs

This is the list of input variables that can be provided to the module. There are some default values already set for this modules which can be overridden otherwise. Please read through the description and default values before handling advance scenarios using this module.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_classic_infra"></a> [classic\_infra](#input\_classic\_infra) | IKS is on classic infra, `true` or `false` | `bool` | `false` | no |
| <a name="input_cloud_drive_options"></a> [cloud\_drive\_options](#input\_cloud\_drive\_options) | cloud\_drive\_options = {<br>  max\_storage\_node\_per\_zone : "Maximum number of strorage nodes per zone, you can set this to the maximum worker nodes in your cluster"<br>  num\_cloud\_drives : "Number of cloud drives per zone, Max: 3"<br>  cloud\_drives\_sizes : "Size of Cloud Drive in GB, ex: [50, 60, 70], the number of elements should be same as the value of `num_cloud_drives`"<br>  storage\_classes : "Storage Classes for each cloud drive, ex: [ "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose"], the number of elements should be same as the value of `num_cloud_drives`"<br>} | <pre>object({<br>    max_storage_node_per_zone = number<br>    num_cloud_drives          = number<br>    cloud_drives_sizes        = list(number)<br>    storage_classes           = list(string)<br>  })</pre> | <pre>{<br>  "cloud_drives_sizes": [<br>    100<br>  ],<br>  "max_storage_node_per_zone": 1,<br>  "num_cloud_drives": 1,<br>  "storage_classes": [<br>    "ibmc-vpc-block-10iops-tier"<br>  ]<br>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of existing IKS cluster | `string` | n/a | yes |
| <a name="input_etcd_secret_name"></a> [etcd\_secret\_name](#input\_etcd\_secret\_name) | The name of etcd secret certificate, required only when external etcd is used | `string` | `null` | no |
| <a name="input_external_etcd_connection_url"></a> [external\_etcd\_connection\_url](#input\_external\_etcd\_connection\_url) | The connection string with port number for the etcd, required only when external etcd is used | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys | `string` | n/a | yes |
| <a name="input_portworx_csi"></a> [portworx\_csi](#input\_portworx\_csi) | Enable Portworx CSI, `true` or `false` | `bool` | `false` | no |
| <a name="input_portworx_service_name"></a> [portworx\_service\_name](#input\_portworx\_service\_name) | Name to be provided to the portworx cluster to be deployed | `string` | `"portworx-enterprise"` | no |
| <a name="input_portworx_version"></a> [portworx\_version](#input\_portworx\_version) | Image Version of Portworx Enterprise | `string` | `"2.11.0"` | no |
| <a name="input_pwx_plan"></a> [pwx\_plan](#input\_pwx\_plan) | Portworx plan type | `string` | `"px-enterprise"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc. | `string` | `"us-east"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group of existing IKS Cluster | `string` | n/a | yes |
| <a name="input_secret_type"></a> [secret\_type](#input\_secret\_type) | secret type | `string` | `"k8s"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional Tags to be add, if required. | `list(string)` | `[]` | no |
| <a name="input_upgrade_portworx"></a> [upgrade\_portworx](#input\_upgrade\_portworx) | Upgrade Portworx Version to the respective `portworx_version`, `true` or `false` | `bool` | `false` | no |
| <a name="input_use_cloud_drives"></a> [use\_cloud\_drives](#input\_use\_cloud\_drives) | Use Cloud Drives, `true` or `false` | `bool` | `true` | no |
| <a name="input_use_external_etcd"></a> [use\_external\_etcd](#input\_use\_external\_etcd) | Do you want to create an external\_etcd? `true` or `false` | `bool` | `false` | no |

## Outputs

This is the list of output variables that can be read or refered post a succesfull `terraform apply`. 

| Name | Description |
|------|-------------|
| <a name="output_associated_iks_cluster_id"></a> [associated\_iks\_cluster\_id](#output\_associated\_iks\_cluster\_id) | The id of the IKS Cluster where Px-Enterprise was Installed |
| <a name="output_associated_iks_cluster_name"></a> [associated\_iks\_cluster\_name](#output\_associated\_iks\_cluster\_name) | The name of the IKS Cluster where Px-Enterprise was Installed |
| <a name="output_portworx_enterprise_id"></a> [portworx\_enterprise\_id](#output\_portworx\_enterprise\_id) | The ID of the PX-Enterprise Resource Instance |
| <a name="output_portworx_enterprise_service_name"></a> [portworx\_enterprise\_service\_name](#output\_portworx\_enterprise\_service\_name) | The name of the PX-Enterprise Resource Instance |
| <a name="output_portworx_version_installed"></a> [portworx\_version\_installed](#output\_portworx\_version\_installed) | The version of PX-Enterprise Deployed on the Cluster |
<!-- END_TF_DOCS -->
## License
Apache License 2.0 - Copyright 2022 Pure Storage, Inc.