output "portworx_enterprise_id" {
  value = ibm_resource_instance.portworx.id
  description = "The ID of the PX-Enterprise Resource Instance"
}

output "portworx_enterprise_service_name" {
  value = ibm_resource_instance.portworx.name
  description = "The name of the PX-Enterprise Resource Instance"
}

output "portworx_version_installed" {
  value = var.portworx_version
  description = "The version of PX-Enterprise Deployed on the Cluster"
}

output "associated_iks_cluster_id" {
  value = local.cluster_ref.id
  description = "The id of the IKS Cluster where Px-Enterprise was Installed"
}

output "associated_iks_cluster_name" {
  value = local.cluster_ref.name
  description = "The name of the IKS Cluster where Px-Enterprise was Installed"
}