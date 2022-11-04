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


variable "etcd_options" {
  description = <<-_EOT
  etcd_options = {
    use_external_etcd : "Do you want to create an external_etcd? `true` or `false`"
    etcd_secret_name : "The name of etcd secret certificate, required only when external etcd is used"
    external_etcd_connection_url : "The connection string with port number for the etcd, required only when external etcd is used"
  }
  _EOT
  type = object({
    use_external_etcd            = bool
    etcd_secret_name             = string
    external_etcd_connection_url = string
  })
  default = {
    use_external_etcd            = false
    etcd_secret_name             = null
    external_etcd_connection_url = null
  }
  validation {
    condition     = (var.etcd_options.use_external_etcd && (var.etcd_options.external_etcd_connection_url != null) && (var.etcd_options.etcd_secret_name != null)) || (!var.etcd_options.use_external_etcd && (var.etcd_options.external_etcd_connection_url == null) && (var.etcd_options.etcd_secret_name == null))
    error_message = "The value of `etcd_secret_name` and `external_etcd_connection_url` should be set when `use_external_etcd` is set to `true`"
  }
}


variable "region" {
  description = "The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc."
  default     = "us-east"
  type        = string
  nullable    = false
}

variable "pwx_plan" {
  description = "Portworx plan type "
  type        = string
  default     = "px-enterprise"
  validation {
    condition     = contains(["px-enterprise", "px-dr-enterprise"], var.pwx_plan)
    error_message = "The value of `pwx_plan` should be any of the following:\npx-enterprise\npx-dr-enterprise"
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
  default     = "2.11.4"
  description = "Image Version of Portworx Enterprise"
  validation {
    condition     = (tonumber(split(".", var.portworx_version)[0]) > 2) || (tonumber(split(".", var.portworx_version)[0]) == 2 && tonumber(split(".", var.portworx_version)[1]) >= 11)
    error_message = "Cloud Drives are only supported for `portworx_version: 2.11.0 and above`"
  }
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


variable "cloud_drive_options" {
  description = <<-_EOT
  cloud_drive_options = {
    max_storage_node_per_zone : "Maximum number of strorage nodes per zone, you can set this to the maximum worker nodes in your cluster"
    num_cloud_drives : "Number of cloud drives per zone, Max: 3"
    cloud_drives_sizes : "Size of Cloud Drive in GB, ex: [50, 60, 70], the number of elements should be same as the value of `num_cloud_drives`"
    storage_classes : "Storage Classes for each cloud drive, ex: [ "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose"], the number of elements should be same as the value of `num_cloud_drives`"
  }
  _EOT
  type = object({
    max_storage_node_per_zone = number
    num_cloud_drives          = number
    cloud_drives_sizes        = list(number)
    storage_classes           = list(string)
  })
  default = {
    max_storage_node_per_zone = 1
    num_cloud_drives          = 1
    cloud_drives_sizes        = [100]
    storage_classes           = ["ibmc-vpc-block-10iops-tier"]
  }
  validation {
    condition     = var.cloud_drive_options.num_cloud_drives >= 1 && var.cloud_drive_options.num_cloud_drives <= 3
    error_message = "The value of `num_cloud_drives` should be an integer, min = 1 and max = 3"
  }
  validation {
    condition     = length(var.cloud_drive_options.cloud_drives_sizes) == length(var.cloud_drive_options.storage_classes) && var.cloud_drive_options.num_cloud_drives == length(var.cloud_drive_options.storage_classes)
    error_message = "The length of `cloud_drives_sizes` list should be equal to the length of `storage_classes` list, and the number of elements in each should be equal to `num_cloud_drives`"
  }
  validation {
    condition = alltrue([
      for sc in var.cloud_drive_options.storage_classes : contains(["ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose", "ibmc-vpc-block-retain-10iops-tier", "ibmc-vpc-block-retain-5iops-tier", "ibmc-vpc-block-retain-general-purpose"], sc)
    ])
    error_message = "The value of `storage_classes` should be a list of strings\nAvailable Options: ibmc-vpc-block-10iops-tier\nibmc-vpc-block-5iops-tier\nibmc-vpc-block-general-purpose\nibmc-vpc-block-retain-10iops-tier\nibmc-vpc-block-retain-5iops-tier\nibmc-vpc-block-retain-general-purpose"
  }
}
