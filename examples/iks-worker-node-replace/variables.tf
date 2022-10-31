variable "resource_group" {
  type        = string
  description = "The name of the Resource Group."
}

variable "region" {
  type        = string
  description = "The name of the Region."
}

variable "iks_cluster_name" {
  type        = string
  description = "The name of the VPC2 IKS Cluster."
}

variable "timeout" {
  type        = string
  description = "The wait time in minutes for Portworx Enterprise to come online after successful Node Replacement."
  default     = "15m"
}

variable "replace_all_workers" {
  type        = bool
  description = "Toggle this to `false` and provide the `worker_ids` list with worker_id of each worker to be replaced."
  default     = true
}

variable "worker_ids" {
  type        = list(string)
  description = "The list of `worker_ids` of the workers to be replaced."
  default     = []
}
