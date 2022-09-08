resource "random_uuid" "unique_id" {
}
resource "ibm_resource_instance" "portworx" {
  name              = "portworx-service-${split("-", random_uuid.unique_id.result)[0]}"
  service           = "portworx"
  plan              = var.pwx_plan
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id

  tags = [
    "clusterid:${local.cluster_ref.id}",
    "managed_by:terraform",
    "cluster_name:${local.cluster_ref.name}",
    "owner:sudas"
  ]
  //TODO: Recheck Tags
  parameters = templatefile("${path.module}/parameters.tftpl", { params = local.params })
  //TODO: fix csi boolean issue


  provisioner "local-exec" {
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_wait_until_ready.sh"
  }
}

resource "null_resource" "portworx_destroy" {
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/utils/"
    command     = "/bin/bash portworx_destroy.sh"
  }
}
