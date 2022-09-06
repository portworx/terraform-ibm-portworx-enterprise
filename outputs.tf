output "portworx_is_ready" {
  value = length(ibm_resource_instance.portworx) > 0 ? ibm_resource_instance.portworx.id : null
}
