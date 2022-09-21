# IBM Cloud Portworx Enterprise Module
Terraform Module which installs Portworx Enterprise on an existing IKS Cluster

## Usage
```terraform
module "portworx-enterprise" {
  source                    = "github.com/portworx/terraform-ibm-portworx-enterprise.git"
  region                    = "us-east"
  cluster_name              = "my-iks-cluster"
  resource_group            = "my-resource-group"
  use_cloud_drives          = true
  classic_infra             = false
  portworx_version          = "2.11.0"
  upgrade_portworx          = false
  max_storage_node_per_zone = 1
  num_cloud_drives          = 1
  cloud_drives_sizes        = [100]
  storage_classes           = "ibmc-vpc-block-10iops-tier"
  tags                      = ["importance:critical"]
}
```
## Getting Started
> Please refer to [this](https://github.com/portworx/terraform-ibm-portworx-enterprise/blob/main/examples/README.md) as a quickstart guide to install Portworx Enterprise on an IKS using Cloud Drives.

## Examples
- [Installation on IKS Cluster created using Classic Infra](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-classic-infra)
- [Installation on IKS Cluster created using VPC Gen 2 with Cloud Drives](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-attached-drives)
- [Installation on IKS Cluster created using VPC Gen 2 with Block Volumes already attached to worker nodes](https://github.com/portworx/terraform-ibm-portworx-enterprise/tree/main/examples/iks-with-cloud-drives)

## Requirements
| Name  | Version |
| ------------- | ------------- |
| terraform  | >= 0.13  |
| kubectl  | >= 1.22.0  |
| jq  | >= 1.6  |
| curl  | >= 7.79.1  |
| wget  | >= 1.21.3  |
| tar  | >= 3.5.1  |
| ibmcloud  | >= 2.10.0  |

## Providers
| Name  | Version |
| ------------- | ------------- |
| ibm-cloud/ibm  | >= v1.45.0  |
| hashicorp/random  | >= 3.4.3  |
| hashicorp/null  | >= 3.1.1  |
## Resources

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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_classic_infra"></a> [classic\_infra](#input\_classic\_infra) | IKS is on classic infra, `true` or `false` | `bool` | `false` | no |
| <a name="input_cloud_drive_options"></a> [cloud\_drive\_options](#input\_cloud\_drive\_options) | cloud\_drive\_options = {<br>  max\_storage\_node\_per\_zone : "Maximum number of strorage nodes per zone, you can set this to the maximum worker nodes in your cluster"<br>  num\_cloud\_drives : "Number of cloud drives per zone, Max: 3"<br>  cloud\_drives\_sizes : "Size of Cloud Drive in GB, ex: [50, 60, 70], the number of elements should be same as the value of `num_cloud_drives`"<br>  storage\_classes : "Storage Classes for each cloud drive, ex: [ "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose"], the number of elements should be same as the value of `num_cloud_drives`"<br>} | <pre>object({<br>    max_storage_node_per_zone = number<br>    num_cloud_drives          = number<br>    cloud_drives_sizes        = list(number)<br>    storage_classes           = list(string)<br>  })</pre> | <pre>{<br>  "cloud_drives_sizes": [<br>    100<br>  ],<br>  "max_storage_node_per_zone": 1,<br>  "num_cloud_drives": 1,<br>  "storage_classes": [<br>    "ibmc-vpc-block-10iops-tier"<br>  ]<br>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of existing IKS cluster | `string` | n/a | yes |
| <a name="input_etcd_options"></a> [etcd\_options](#input\_etcd\_options) | etcd\_options = {<br>  use\_external\_etcd : "Do you want to create an external\_etcd? `true` or `false`"<br>  etcd\_secret\_name : "The name of etcd secret certificate, required only when external etcd is used"<br>  external\_etcd\_connection\_url : "The connection string with port number for the etcd, required only when external etcd is used"<br>} | <pre>object({<br>    use_external_etcd            = bool<br>    etcd_secret_name             = string<br>    external_etcd_connection_url = string<br>  })</pre> | <pre>{<br>  "etcd_secret_name": null,<br>  "external_etcd_connection_url": null,<br>  "use_external_etcd": false<br>}</pre> | no |
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


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_associated_iks_cluster_id"></a> [associated\_iks\_cluster\_id](#output\_associated\_iks\_cluster\_id) | The id of the IKS Cluster where Px-Enterprise was Installed |
| <a name="output_associated_iks_cluster_name"></a> [associated\_iks\_cluster\_name](#output\_associated\_iks\_cluster\_name) | The name of the IKS Cluster where Px-Enterprise was Installed |
| <a name="output_portworx_enterprise_id"></a> [portworx\_enterprise\_id](#output\_portworx\_enterprise\_id) | The ID of the PX-Enterprise Resource Instance |
| <a name="output_portworx_enterprise_service_name"></a> [portworx\_enterprise\_service\_name](#output\_portworx\_enterprise\_service\_name) | The name of the PX-Enterprise Resource Instance |
| <a name="output_portworx_version_installed"></a> [portworx\_version\_installed](#output\_portworx\_version\_installed) | The version of PX-Enterprise Deployed on the Cluster |
<!-- END_TF_DOCS -->
## Authors

## License
Apache License 2.0 - Copyright 2022 Pure Storage, Inc.