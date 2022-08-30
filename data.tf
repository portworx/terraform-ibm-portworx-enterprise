data "ibm_iam_auth_token" "token" {}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_vpc_cluster" "cluster" {
  name              = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id   = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
  admin             = true
  config_dir        = path.root
}

data "ibm_container_vpc_cluster_worker" "worker" {
  count             = length(data.ibm_container_vpc_cluster.cluster.workers)
  worker_id         = element(data.ibm_container_vpc_cluster.cluster.workers, count.index)
  cluster_name_id   = data.ibm_container_vpc_cluster.cluster.id
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_is_subnet" "subnet" {
  count      = length(data.ibm_container_vpc_cluster_worker.worker)
  identifier = data.ibm_container_vpc_cluster_worker.worker[count.index].network_interfaces[0].subnet_id
}
