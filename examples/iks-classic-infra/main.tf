module "portworx-enterprise" {
  // IBM Provider Configuration
  source           = "github.com/portworx/terraform-ibm-portworx-enterprise.git"
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
  use_cloud_drives      = var.use_cloud_drives
  portworx_csi          = var.portworx_csi
  portworx_service_name = var.portworx_service_name
  secret_type           = var.secret_type
}
