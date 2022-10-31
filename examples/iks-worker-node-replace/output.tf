# Show the ID's of workers to replace
output "workers_to_replace" {
  value       = local.workers
  description = "ID's of workers to replace"
}

# Show the new ID's of workers that have been replaced
output "replaced_workers" {
  value       = ibm_container_vpc_worker.workers.*.id
  description = "New ID's of workers that have been replaced"
}
