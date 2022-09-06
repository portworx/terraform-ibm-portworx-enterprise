data "ibm_iam_auth_token" "token" {}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_vpc_cluster" "cluster" {
  count             = var.classic_infra ? 0 : 1
  name              = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_vpc_cluster_worker" "worker" {
  count             = var.classic_infra ? 0 : length(data.ibm_container_vpc_cluster.cluster.workers)
  worker_id         = element(data.ibm_container_vpc_cluster.cluster.workers, count.index)
  cluster_name_id   = data.ibm_container_vpc_cluster.cluster.id
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster" "cluster_classic" {
  count = var.classic_infra ? 1 : 0
  name = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster_worker" "worker_classic" {
  count             = var.classic_infra ? 0 : length(data.ibm_container_cluster.cluster_classic.workers)
  worker_id         = element(data.ibm_container_cluster.cluster_classic.workers, count.index)
  cluster_name_id   = data.ibm_container_cluster.cluster_classic.id
  resource_group_id = data.ibm_resource_group.group.id
}