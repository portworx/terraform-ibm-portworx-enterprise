module "portworx-enterprise" {
  source = "github.com/portworx/terraform-ibm-portworx-enterprise.git?ref=PWX-26622"
  //TODO: Find a way to read the ibm_api_key from environment variable
  ibmcloud_api_key = var.ibmcloud_api_key
  cluster_name   = var.iks_cluster_name
  resource_group = var.resource_group
  use_cloud_drives = var.use_cloud_drives
  classic_infra = var.classic_infra
  portworx_version = var.portworx_version
  upgrade_portworx = var.upgrade_portworx
}
