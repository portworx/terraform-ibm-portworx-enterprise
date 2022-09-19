module "portworx-enterprise" {
  // IBM Provider Configuration
  source           = "github.com/portworx/terraform-ibm-portworx-enterprise.git?ref=PWX-27061"
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key

  // IKS Cluster Configuration
  cluster_name   = var.iks_cluster_name
  resource_group = var.resource_group
  classic_infra  = var.classic_infra

  // External ETCD Configuration
  use_external_etcd            = var.use_external_etcd
  etcd_secret_name             = var.etcd_secret_name
  external_etcd_connection_url = var.external_etcd_connection_url

  // Portworx Enterprise Configuration
  pwx_plan              = var.pwx_plan
  portworx_version      = var.portworx_version
  upgrade_portworx      = var.upgrade_portworx
  portworx_csi          = var.portworx_csi
  portworx_service_name = var.portworx_service_name
  secret_type           = var.secret_type
  
  // Cloud Drives Configuration
  use_cloud_drives          = var.use_cloud_drives
  max_storage_node_per_zone = var.max_storage_node_per_zone
  num_cloud_drives          = var.num_cloud_drives
  cloud_drives_sizes        = var.cloud_drives_sizes
  storage_classes           = var.storage_classes
}
