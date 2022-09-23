output "portworx_enterprise_id" {
  value       = module.portworx_enterprise.portworx_enterprise_id
  description = "The ID of the Portworx-Enterprise Resource Instance"
}
output "portworx_enterprise_service_name" {
  value       = module.portworx_enterprise.portworx_enterprise_service_name
  description = "The name of the Portworx-Enterprise Resource Instance"
}
output "portworx_version_installed" {
  value       = module.portworx_enterprise.portworx_version_installed
  description = "The version of Portworx-Enterprise Deployed on the Cluster"
}
output "associated_iks_cluster_id" {
  value       = module.portworx_enterprise.associated_iks_cluster_id
  description = "The id of the IKS Cluster where Portworx-Enterprise was Installed"
}
output "associated_iks_cluster_name" {
  value       = module.portworx_enterprise.associated_iks_cluster_name
  description = "The name of the IKS Cluster where Portworx-Enterprise was Installed"
}
