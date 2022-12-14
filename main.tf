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
    apikey                    = var.ibmcloud_api_key
    cluster_name              = local.px_cluster_name
    clusters                  = var.cluster_name
    etcd_endpoint             = var.etcd_options.use_external_etcd ? var.etcd_options.external_etcd_connection_url : null
    etcd_secret               = var.etcd_options.use_external_etcd ? var.etcd_options.etcd_secret_name : null
    internal_kvdb             = var.etcd_options.use_external_etcd ? "external" : "internal"
    image_version             = var.portworx_version
    secret_type               = var.secret_type
    csi                       = var.portworx_csi ? "True" : "False"
    cloud_drive               = var.use_cloud_drives ? "Yes" : "No"
    max_storage_node_per_zone = 1
    num_cloud_drives          = var.cloud_drive_options.num_cloud_drives
    size                      = (var.cloud_drive_options.num_cloud_drives >= 1) ? element(var.cloud_drive_options.cloud_drives_sizes, 0) : 0
    size2                     = (var.cloud_drive_options.num_cloud_drives >= 2) ? element(var.cloud_drive_options.cloud_drives_sizes, 1) : 0
    size3                     = (var.cloud_drive_options.num_cloud_drives == 3) ? element(var.cloud_drive_options.cloud_drives_sizes, 2) : 0
    storageClassName          = (var.cloud_drive_options.num_cloud_drives >= 1) ? element(var.cloud_drive_options.storage_classes, 0) : ""
    storageClassName2         = (var.cloud_drive_options.num_cloud_drives >= 2) ? element(var.cloud_drive_options.storage_classes, 1) : ""
    storageClassName3         = (var.cloud_drive_options.num_cloud_drives == 3) ? element(var.cloud_drive_options.storage_classes, 2) : ""
    namespace                 = var.namespace
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_wait_until_ready.sh ${local.px_cluster_name} ${var.namespace}"
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

resource "null_resource" "portworx_configure_max_storage_node_per_zone" {
  triggers = {
    max_storage_node_per_zone = var.cloud_drive_options.max_storage_node_per_zone
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_configure_max_storage_node_per_zone.sh ${self.triggers.max_storage_node_per_zone} ${local.px_cluster_name} ${var.namespace}"
    on_failure  = fail
  }

  depends_on = [
    ibm_resource_instance.portworx
  ]
}

resource "null_resource" "portworx_upgrade" {
  triggers = {
    condition = var.upgrade_portworx
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_upgrade.sh ${var.portworx_version} ${var.upgrade_portworx} ${local.px_cluster_name} ${var.namespace}"
    on_failure  = fail
  }
}

resource "null_resource" "portworx_install_autopilot" {
  triggers = {
    condition = var.install_autopilot
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_install_autopilot.sh ${var.namespace} ${local.px_cluster_name} ${var.prometheus_url}"
    on_failure  = fail
  }

  depends_on = [
    ibm_resource_instance.portworx
  ]
}

resource "null_resource" "portworx_destroy" {
  triggers = {
    ds = var.delete_strategy
    ns = var.namespace
  }
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_destroy.sh ${self.triggers.ds} ${self.triggers.ns}"
    on_failure  = fail
  }
}
