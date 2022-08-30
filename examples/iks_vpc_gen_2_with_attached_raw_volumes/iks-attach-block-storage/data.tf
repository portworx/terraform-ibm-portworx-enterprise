data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

data "ibm_container_vpc_cluster" "cluster" {
  name              = var.iks_cluster_name
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_container_vpc_cluster_worker" "worker" {
  count             = data.ibm_container_vpc_cluster.cluster.worker_count
  worker_id         = element(data.ibm_container_vpc_cluster.cluster.workers, count.index)
  cluster_name_id   = data.ibm_container_vpc_cluster.cluster.id
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_is_subnet" "subnets" {
  count      = data.ibm_container_vpc_cluster.cluster.worker_count
  identifier = data.ibm_container_vpc_cluster_worker.worker[count.index].network_interfaces[0].subnet_id
}
