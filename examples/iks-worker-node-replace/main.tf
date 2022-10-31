# IBM Resource to replace a worker node with Portworx Enterprise Running on the Node

# This resource replaces all the worker nodes in an IKS Cluster
resource "ibm_container_vpc_worker" "workers" {
  count             = length(local.workers)
  cluster_name      = var.iks_cluster_name
  replace_worker    = element(local.workers, count.index)
  resource_group_id = data.ibm_resource_group.resource_group.id
  kube_config_path  = data.ibm_container_cluster_config.cluster.config_file_path
  check_ptx_status  = "true"
  ptx_timeout       = var.timeout
}
