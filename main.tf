resource "ibm_resource_instance" "portworx" {
  depends_on = [
    ibm_container_storage_attachment.volume_attach,
    kubernetes_secret.etcd,
  ]

  name              = "${var.unique_id}-portworx-service"
  service           = "portworx"
  plan              = var.pwx_plan
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id

  tags = [
    "clusterid:${data.ibm_container_vpc_cluster.cluster.id}",
  ]

  parameters = {
    apikey       = var.ibmcloud_api_key
    cluster_name = var.cluster_name
    clusters     = data.ibm_container_vpc_cluster.cluster.id
    etcd_endpoint = (var.create_external_etcd ?
      "etcd:https://${local.etcd_user_connectionstring.hosts[0].hostname}:${local.etcd_user_connectionstring.hosts[0].port}"
      : null
    )
    etcd_secret      = var.create_external_etcd ? var.etcd_secret_name : null
    internal_kvdb    = var.create_external_etcd ? "external" : "internal"
    portworx_version = "Portworx: 2.6.2.1 , Stork: 2.6.0"
    secret_type      = var.secret_type
  }

  # provisioner "local-exec" {
  #   environment = {
  #     KUBECONFIG = var.kube_config_path
  #   }
  #   interpreter = ["/bin/bash", "-c"]
  #   command     = file("${path.module}/utils/px_wait_until_ready.sh")
  # }
}