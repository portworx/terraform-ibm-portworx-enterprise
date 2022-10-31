# Get the resource group ID for the resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}
# Get the kube_config for the cluster and store in the Root Module Directory
data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = data.ibm_container_vpc_cluster.cluster.id
  config_dir      = path.root
}
# Get all the workers from the clusters
data "ibm_container_vpc_cluster" "cluster" {
  name              = var.iks_cluster_name
  resource_group_id = data.ibm_resource_group.resource_group.id
}
# Local variables, NOTE: Always get the list of workers into a local varibale first and then pass this local varibale to the `ibm_container_vpc_worker.resource` resource
# DO NOT USE the `data.ibm_container_vpc_cluster.cluster.workers` variable directly in the `ibm_container_vpc_worker.worker` resource
locals {
  workers = var.replace_all_workers ? data.ibm_container_vpc_cluster.cluster.workers : var.worker_ids
}
