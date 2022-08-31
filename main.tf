resource "ibm_resource_instance" "portworx" {
  name              = "${var.unique_id}-portworx-service"
  service           = "portworx"
  plan              = var.pwx_plan
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id

  tags = [
    "clusterid:${data.ibm_container_vpc_cluster.cluster.id}",
  ]

  parameters = {
    apikey           = var.ibmcloud_api_key
    cluster_name     = var.cluster_name
    clusters         = data.ibm_container_vpc_cluster.cluster.id
    etcd_endpoint    = var.use_external_etcd ? var.external_etcd_connection_url : null
    etcd_secret      = var.use_external_etcd ? var.etcd_secret_name : null
    internal_kvdb    = var.use_external_etcd ? "external" : "internal"
    portworx_version = "Portworx: 2.6.2.1 , Stork: 2.6.0"
    secret_type      = var.secret_type
  }

  provisioner "local-exec" {
    command     = file("${path.module}/utils/portworx_wait_until_ready.sh")
  }
}
resource "null_resource" "portworx_destroy" {
  provisioner "local-exec" {
    when    = destroy
    working_dir = "${path.module}/utils/"
    command = file("${path.module}/utils/portworx_destroy.sh")
  }
}