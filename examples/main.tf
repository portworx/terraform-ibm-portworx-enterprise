module "portworx-enterprise" {
  source = "github.com/portworx/terraform-ibm-portworx-enterprise.git"
  region = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  cluster_name   = var.iks_cluster_name
  resource_group = var.resource_group
  use_cloud_drives = var.use_cloud_drives
  classic_infra = var.classic_infra
  portworx_version = var.portworx_version
  upgrade_portworx = var.upgrade_portworx
  max_storage_node_per_zone = var.max_storage_node_per_zone
  num_cloud_drives = var.num_cloud_drives
  cloud_drives_sizes = var.cloud_drives_sizes
  storage_classes = var.storage_classes
}
