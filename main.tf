resource "null_resource" "preflight_checks" {
  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash preflight_node_health.sh"
    on_failure  = continue
  }
}
resource "random_uuid" "unique_id" {
}
resource "ibm_resource_instance" "portworx" {
  name              = "${var.portworx_service_name}-${split("-", random_uuid.unique_id.result)[0]}"
  service           = "portworx"
  plan              = var.pwx_plan
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id

  tags = concat([
    "clusterid:${local.cluster_ref.id}",
    "managed_by:portworx_enterprise_terraform",
    "cluster_name:${local.cluster_ref.name}"
  ], var.tags)

  parameters = {
    apikey                    = var.ibmcloud_api_key,
    cluster_name              = var.cluster_name,
    clusters                  = var.cluster_name,
    etcd_endpoint             = var.use_external_etcd ? var.external_etcd_connection_url : null,
    etcd_secret               = var.use_external_etcd ? var.etcd_secret_name : null,
    internal_kvdb             = var.use_external_etcd ? "external" : "internal",
    image_version             = var.portworx_version,
    secret_type               = var.secret_type,
    csi                       = var.portworx_csi ? "True" : "False",
    cloud_drive               = var.use_cloud_drives ? "Yes" : "No",
    max_storage_node_per_zone = var.max_storage_node_per_zone,
    num_cloud_drives          = var.num_cloud_drives,
    size                      = element(var.cloud_drives_sizes, 0),
    size2                     = (var.num_cloud_drives == 2) ? element(var.cloud_drives_sizes, 1) : 0,
    size3                     = (var.num_cloud_drives == 3) ? element(var.cloud_drives_sizes, 2) : 0,
    storageClassName          = element(var.storage_classes, 0),
    storageClassName2         = (var.num_cloud_drives == 2) ? element(var.storage_classes, 1) : "",
    storageClassName3         = (var.num_cloud_drives == 3) ? element(var.storage_classes, 2) : ""
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_wait_until_ready.sh"
    on_failure  = fail
  }
  lifecycle {
    ignore_changes = [
      parameters["image_version"]
    ]
  }
  depends_on = [
    null_resource.preflight_checks
  ]
}

resource "null_resource" "portworx_upgrade" {
  triggers = {
    condition = timestamp()
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_upgrade.sh ${var.portworx_version} ${var.upgrade_portworx}"
    on_failure  = fail
  }
}

resource "null_resource" "portworx_destroy" {
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_destroy.sh"
    on_failure  = fail
  }
}
