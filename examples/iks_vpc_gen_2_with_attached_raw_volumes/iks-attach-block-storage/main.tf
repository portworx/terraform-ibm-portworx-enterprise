# Storage
resource "ibm_is_volume" "volumes" {
  count          = data.ibm_container_vpc_cluster.cluster.worker_count
  name           = "vol-workers-${element(split("-", data.ibm_container_vpc_cluster.cluster.workers[count.index]), 4)}"
  profile        = "10iops-tier"
  zone           = data.ibm_is_subnet.subnets[count.index].zone
  resource_group = data.ibm_resource_group.resource_group.id
  capacity       = var.capacity
}

resource "ibm_container_storage_attachment" "volume_attach" {
  count   = data.ibm_container_vpc_cluster.cluster.worker_count
  volume  = ibm_is_volume.volumes[count.index].id
  cluster = data.ibm_container_vpc_cluster.cluster.id
  worker  = data.ibm_container_vpc_cluster_worker.worker[count.index].id
}
