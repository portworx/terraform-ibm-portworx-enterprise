module "portworx-enterprise" {
  source = "github.com/portworx/terraform-ibm-portworx-enterprise.git?ref=f69ef4f"
  //TODO: Find a way to read the ibm_api_key from environment variable
  ibmcloud_api_key = var.ibmcloud_api_key
  cluster_name   = var.iks_cluster_name
  resource_group = var.resource_group
  use_cloud_drives = var.use_cloud_drives
}
