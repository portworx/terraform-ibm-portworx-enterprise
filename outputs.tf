output "portworx_is_ready" {
  value = var.classic_infra ? ibm_resource_instance.portworx_on_classic[0].id : ibm_resource_instance.portworx[0].id
}
