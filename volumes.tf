resource "ibm_is_volume" "volume" {

  depends_on = [
    data.ibm_is_subnet.subnet
  ]

  count = var.install_storage ? length(data.ibm_container_vpc_cluster.cluster.workers) : 0

  name           = "vol-workerss-${element(split("-", data.ibm_container_vpc_cluster.cluster.workers[count.index]), 4)}"
  profile        = var.profile
  zone           = data.ibm_is_subnet.subnet[count.index].zone
  resource_group = data.ibm_resource_group.group.id
  capacity       = var.capacity
}


resource "ibm_container_storage_attachment" "volume_attach" {
  count   = var.install_storage ? length(data.ibm_container_vpc_cluster_worker.worker) : 0
  volume  = ibm_is_volume.volume[count.index].id
  cluster = data.ibm_container_vpc_cluster.cluster.id
  worker  = data.ibm_container_vpc_cluster_worker.worker[count.index].id
}

