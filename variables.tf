//TODO: Add Descriptions
variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of existing roks cluster"
  type        = string
}

variable "resource_group" {
  description = "Resource group of existing cluster"
  type        = string
}

variable "use_external_etcd" {
  type        = bool
  default     = false
  description = "Do you want to create an external_etcd? `True` or `False`"
}

variable "etcd_secret_name" {
  type        = string
  description = "The name of etcd secret certificate, required only when external etcd is used"
  default     = null
}

variable "external_etcd_connection_url" {
  type        = string
  description = "The connection string with port number for the etcd, required only when external etcd is used"
  default     = null
}


variable "region" {
  description = "The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc."
  default     = "us-east"
  type        = string
}

variable "pwx_plan" {
  description = "Portworx plan type "
  type        = string
  default     = "px-enterprise"
}
variable "secret_type" {
  description = "secret type"
  type        = string
  default     = "k8s"
}

variable "use_cloud_drives" {
  type        = bool
  description = "(optional) describe your variable"
  default     = false
}
variable "max_storage_node_per_zone" {
  type        = number
  description = "(optional) describe your variable"
  default     = 1
}

variable "num_cloud_drives" {
  type        = number
  description = "(optional) describe your variable"
  default     = 1
}

variable "cloud_drives_sizes" {
  type        = list(number)
  description = "(optional) describe your variable"
  default     = [100, 100, 100]
}

variable "storage_classes" {
  type        = list(string)
  description = "(optional) describe your variable"
  default     = ["ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-10iops-tier"]
}

variable "csi" {
  type        = bool
  description = "(optional) describe your variable"
  default     = false
}
variable "classic_infra" {
  type = bool
  description = "(optional) describe your variable"
  default     = false
}
variable "portworx_version" {
  type = string
  default = "2.11.0"
  description = "(optional) describe your variable"
}