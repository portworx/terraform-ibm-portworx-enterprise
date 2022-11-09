data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_vpc_cluster" "cluster" {
  count             = var.classic_infra ? 0 : 1
  name              = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster" "cluster_classic" {
  count             = var.classic_infra ? 1 : 0
  name              = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}


locals {
  cluster_ref     = var.classic_infra ? data.ibm_container_cluster.cluster_classic[0] : data.ibm_container_vpc_cluster.cluster[0]
  px_cluster_name = "portworx-cluster-${local.cluster_ref.id}"
}
