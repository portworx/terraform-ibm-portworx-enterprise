resource "ibm_database" "etcd" {
  count                        = var.create_external_etcd ? 1 : 0
  location                     = var.region
  members_cpu_allocation_count = var.cpu_allocation_count
  members_disk_allocation_mb   = var.disk_allocation_mb
  members_memory_allocation_mb = var.memory_allocation_mb
  name                         = "${var.unique_id}-pwx-etcd"
  plan                         = var.db_plan
  resource_group_id            = data.ibm_resource_group.group.id
  service                      = "databases-for-etcd"
  service_endpoints            = var.service_endpoints
  version                      = var.db_version
  users {
    name     = var.etcd_username
    password = var.etcd_password
  }
}

# find the object in the connectionstrings list in which the `name` is var.etcd_username
locals {
  etcd_user_connectionstring = (var.create_external_etcd ?
    ibm_database.etcd[0].connectionstrings[index(ibm_database.etcd[0].connectionstrings[*].name, var.etcd_username)] :
  null)
}

resource "kubernetes_secret" "etcd" {
  count = var.create_external_etcd ? 1 : 0

  metadata {
    name      = var.etcd_secret_name
    namespace = var.kubernetes_secret_namespace
  }

  data = {
    "ca.pem" = base64decode(local.etcd_user_connectionstring.certbase64)
    username = var.etcd_username
    password = var.etcd_password
  }

}
