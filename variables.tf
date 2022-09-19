variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "cluster_name" {
  description = "Name of existing IKS cluster"
  type        = string
  nullable    = false
}

variable "resource_group" {
  description = "Resource group of existing IKS Cluster "
  type        = string
  nullable    = false
}

variable "use_external_etcd" {
  type        = bool
  default     = false
  description = "Do you want to create an external_etcd? `true` or `false`"
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
  nullable    = false
}

//TODO: `px-enterprise-dr` is not valid, have to replace it
variable "pwx_plan" {
  description = "Portworx plan type "
  type        = string
  default     = "px-enterprise"
  validation {
    condition     = contains(["px-enterprise", "px-enterprise-dr"], var.pwx_plan)
    error_message = "The value of `pwx_plan` should be any of the following:\npx-enterprise\npx-enterprise-dr"
  }
}

variable "secret_type" {
  description = "secret type"
  type        = string
  default     = "k8s"
}

variable "use_cloud_drives" {
  type        = bool
  description = "Use Cloud Drives, `true` or `false`"
  default     = true
}

variable "max_storage_node_per_zone" {
  type        = number
  description = "Maximum number of strorage nodes per zone, you can set this to the maximum worker nodes in your cluster"
  default     = 1
}

variable "num_cloud_drives" {
  type        = number
  description = "Number of cloud drives per zone, Max: 3"
  default     = 1
  validation {
    condition     = var.num_cloud_drives >= 1 && var.num_cloud_drives <= 3
    error_message = "The value of `num_cloud_drives` should be an integer, min = 1 and max = 3"
  }
}

variable "cloud_drives_sizes" {
  type        = list(number)
  description = "Size of Cloud Drive in GB, ex: [50, 60, 70], the number of elements should be same as the value of `num_cloud_drives`"
  default     = [100]
}

variable "storage_classes" {
  type        = list(string)
  description = "Storage Classes for each cloud drive"
  default     = ["ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-10iops-tier"]
  validation {
    condition = alltrue([
      for sc in var.storage_classes : contains(["ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose", "ibmc-vpc-block-retain-10iops-tier", "ibmc-vpc-block-retain-5iops-tier", "ibmc-vpc-block-retain-general-purpose"], sc)
    ])
    error_message = "The value of `storage_classes` should be a list of strings\nAvailable Options: ibmc-vpc-block-10iops-tier\nibmc-vpc-block-5iops-tier\nibmc-vpc-block-general-purpose\nibmc-vpc-block-retain-10iops-tier\nibmc-vpc-block-retain-5iops-tier\nibmc-vpc-block-retain-general-purpose"
  }
}

variable "portworx_csi" {
  type        = bool
  description = "Enable Portworx CSI, `true` or `false`"
  default     = false
}

variable "classic_infra" {
  type        = bool
  description = "IKS is on classic infra, `true` or `false`"
  default     = false
}

variable "portworx_version" {
  type        = string
  default     = "2.11.0"
  description = "Image Version of Portworx Enterprise"
}

variable "upgrade_portworx" {
  type        = bool
  description = "Upgrade Portworx Version to the respective `portworx_version`, `true` or `false`"
  default     = false
}

variable "portworx_service_name" {
  type        = string
  description = "Name to be provided to the portworx cluster to be deployed"
  default     = "portworx-enterprise"
  nullable    = false
}


variable "tags" {
  type        = list(string)
  description = "Optional Tags to be add, if required."
  default     = []
}
