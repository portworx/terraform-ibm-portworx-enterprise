output "portworx_is_ready" {
  value = var.classic_infra ? ibm_resource_instance.portworx_on_classic.id : ibm_resource_instance.portworx.id
}
