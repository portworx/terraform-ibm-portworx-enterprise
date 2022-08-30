output "volume_name" {
  value = ibm_container_storage_attachment.volume_attach.*.volume_attachment_name
}
output "volume_type" {
  value = ibm_container_storage_attachment.volume_attach.*.volume_type
}
output "volume_id" {
  value = ibm_container_storage_attachment.volume_attach.*.id
}
