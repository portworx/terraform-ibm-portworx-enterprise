# Network
resource "ibm_is_vpc" "vpc" {
  name = "sudas-iks-vpc"
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_subnet" "subnets" {
  count                    = 3
  name                     = "sudas-iks-sn-0${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.resource_group.id
  zone                     = "us-east-${count.index + 1}"
  total_ipv4_address_count = 256
}


# IKS Cluster
resource "ibm_container_vpc_cluster" "cluster" {
  name   = "sudas-iks-k8s-cluster"
  vpc_id = ibm_is_vpc.vpc.id
  flavor = "bx2.4x16"
  # This worker_count is per zone
  worker_count      = 1
  resource_group_id = data.ibm_resource_group.resource_group.id
  zones {
    subnet_id = ibm_is_subnet.subnets[0].id
    name      = "us-east-1"
  }
  zones {
    subnet_id = ibm_is_subnet.subnets[1].id
    name      = "us-east-2"
  }
  zones {
    subnet_id = ibm_is_subnet.subnets[2].id
    name      = "us-east-3"
  }
}


# Storage
resource "ibm_is_volume" "volumes" {
  count = 3
  name           = "vol-workers-${count.index}"
  profile        = "10iops-tier"
  zone           = ibm_is_subnet.subnets[count.index].zone
  resource_group = data.ibm_resource_group.resource_group.id
  capacity       = 100
}

resource "ibm_container_storage_attachment" "volume_attach" {
  count   = 3
  volume  = ibm_is_volume.volumes[count.index].id
  cluster = ibm_container_vpc_cluster.cluster.id
  worker  = data.ibm_container_vpc_cluster_worker.worker[count.index].id
}