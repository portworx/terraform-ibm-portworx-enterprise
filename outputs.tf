output "portworx_is_ready" {
  depends_on = [
    ibm_resource_instance.portworx
  ]
  value = length(ibm_resource_instance.portworx) > 0 ? ibm_resource_instance.portworx.id : null
}
