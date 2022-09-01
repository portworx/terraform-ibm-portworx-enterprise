//TODO: Add Descriptions
variable "region" {
  type        = string
  description = "(optional) describe your variable"
  default     = "us-east"
}

variable "iks_cluster_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "resource_group" {
  type        = string
  description = "(optional) describe your variable"
}

variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive   = true
}