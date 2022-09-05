resource "random_uuid" "unique_id" {
}

resource "ibm_resource_instance" "portworx" {
  name              = "portworx-service-${split("-",random_uuid.unique_id.result )[0]}"
  service           = "portworx"
  plan              = var.pwx_plan
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id

  tags = [
    "clusterid:${data.ibm_container_vpc_cluster.cluster.id}",
    "managed_by:terraform",
    "cluster_name:${data.ibm_container_vpc_cluster.cluster.name}"
  ]

  parameters = {
    apikey                    = var.ibmcloud_api_key
    cluster_name              = var.cluster_name
    clusters                  = data.ibm_container_vpc_cluster.cluster.id
    etcd_endpoint             = var.use_external_etcd ? var.external_etcd_connection_url : null
    etcd_secret               = var.use_external_etcd ? var.etcd_secret_name : null
    internal_kvdb             = var.use_external_etcd ? "external" : "internal"
    portworx_version          = "Portworx: 2.11.0 , Stork: 2.11.0"
    secret_type               = var.secret_type
    cloud_drives              = "Yes"
    max_storage_node_per_zone = 1
    num_cloud_drives          = 1
    size                      = 100
    storageClassName          = "ibmc-vpc-block-10iops-tier"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command = "/bin/bash portworx_wait_until_ready.sh"
  }
}
resource "null_resource" "portworx_destroy" {
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_destroy.sh"
  }
}
