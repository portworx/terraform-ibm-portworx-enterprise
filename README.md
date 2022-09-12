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
