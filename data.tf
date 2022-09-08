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
  count             = var.classic_infra ? 0 : length(data.ibm_container_vpc_cluster.cluster[0].workers)
  worker_id         = element(data.ibm_container_vpc_cluster.cluster[0].workers, count.index)
  cluster_name_id   = data.ibm_container_vpc_cluster.cluster[0].id
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster" "cluster_classic" {
  count             = var.classic_infra ? 1 : 0
  name              = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_container_cluster_worker" "worker_classic" {
  count             = var.classic_infra ? length(data.ibm_container_cluster.cluster_classic[0].workers) : 0
  worker_id         = element(data.ibm_container_cluster.cluster_classic[0].workers, count.index)
  resource_group_id = data.ibm_resource_group.group.id
}

locals {
  cluster_ref = var.classic_infra ? data.ibm_container_cluster.cluster_classic[0] : data.ibm_container_vpc_cluster.cluster[0]
  params = {
    ibmcloud_api_key          = var.ibmcloud_api_key,
    cluster_name              = var.cluster_name,
    clusters                  = var.cluster_name,
    etcd_endpoint             = var.use_external_etcd ? var.external_etcd_connection_url : null,
    etcd_secret               = var.use_external_etcd ? var.etcd_secret_name : null,
    internal_kvdb             = var.use_external_etcd ? "external" : "internal",
    image_version             = var.portworx_version,
    secret_type               = var.secret_type,
    csi                       = var.csi ? "True" : "False",
    use_cloud_drives          = var.use_cloud_drives ? "Yes" : "No",
    max_storage_node_per_zone = var.max_storage_node_per_zone,
    num_cloud_drives          = var.num_cloud_drives,
    size                      = element(var.cloud_drives_sizes, 0),
    size2                     = (var.num_cloud_drives == 2) ? element(var.cloud_drives_sizes, 1) : 0,
    size3                     = (var.num_cloud_drives == 3) ? element(var.cloud_drives_sizes, 2) : 0,
    storageClassName          = element(var.storage_classes, 0),
    storageClassName2         = (var.num_cloud_drives == 2) ? element(var.storage_classes, 1) : "",
    storageClassName3         = (var.num_cloud_drives == 3) ? element(var.storage_classes, 2) : ""
  }
}
