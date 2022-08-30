##############################################################################
# Account Variables
##############################################################################
variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive = true
}

variable "unique_id" {
  description = "Unique identifiers for all created resources"
  type        = string
}

variable "cluster" {
  description = "Name of existing roks cluster"
  type        = string
}

variable "kube_config_path" {
  description = "Path to store k8s config file: ex `~/.kube/config`"
  type        = string
}

variable "resource_group" {
  description = "Resource group of existing cluster"
  type        = string
}

##############################################################################

##############################################################################
# Portworx Variables
##############################################################################
variable "use_external_etcd" {
  type        = bool
  default     = false
  description = "Do you want to create an external_etcd? `True` or `False`"
}

variable "etcd_secret_name" {
  type = string
  description = "The name of etcd secret certificate, required only when external etcd is used"
  default = null
}

variable "external_etcd_connection_url" {
  type = string
  description = "The connection string with port number for the etcd, required only when external etcd is used"
  default = null
}


variable "region" {
  description = "The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc."
  default = "us-east"
  type = string
}

##############################################################################

##############################################################################
# Database Variables
##############################################################################

variable "cpu_allocation_count" {
  description = "Enables and allocates the number of specified dedicated cores to your deployment"
  type        = number
  default     = 9
}

variable "disk_allocation_mb" {
  description = "The amount of disk space for the database, split across all members."
  type        = number
  default     = 393216
}

variable "memory_allocation_mb" {
  description = "The amount of memory in megabytes for the database, split across all members."
  type        = number
  default     = 24576
}

variable "db_plan" {
  description = "The name of the service plan that you choose for db instance. "
  type        = string
  default     = "standard"
}

variable "service_endpoints" {
  description = "Specify whether you want to enable the public, private, or both service endpoints. Supported values are public, private, or public-and-private"
  type        = string
  default     = "public"
}

variable "db_version" {
  description = "The version of the database to be provisioned. "
  type        = string
  default     = "3.3"
}

variable "kubernetes_secret_namespace" {
  description = "Name of the namespace"
  type        = string
  default     = "kube-system"
}

variable "pwx_plan" {
  description = "Portworx plan type "
  type        = string
  default     = "px-enterprise"
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "pwx"
}

variable "secret_type" {
  description = "secret type"
  type        = string
  default     = "k8s"
}
