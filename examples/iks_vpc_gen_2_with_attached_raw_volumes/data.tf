data "ibm_resource_group" "resource_group" {
  name = "Portworx-Dev"
}

data "ibm_container_vpc_cluster" "cluster" {
  name              = ibm_container_vpc_cluster.cluster.name
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_container_vpc_cluster_worker" "worker" {
  count = 3
  worker_id         = element(data.ibm_container_vpc_cluster.cluster.workers, count.index)
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  resource_group_id = data.ibm_resource_group.resource_group.id
}