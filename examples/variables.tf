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
variable "use_cloud_drives" {
  type = bool
  description = "(optional) describe your variable"
  default = false
}

variable "classic_infra" {
  type = bool
  default = false
  description = "(optional) describe your variable"
}

variable "portworx_version" {
  type = string
  default = "2.11.0"
  description = "(optional) describe your variable"
}

variable "upgrade_portworx" {
  type = bool
  description = "(optional) describe your variable"
  default = false
}

variable "kubeconfig_path" {
  type = string
  default = "~/.kube/config"
}

variable "k8s_context" {
  type = string
  default = "sudas-px-tf-cd-fc83a3e7-vanilla/ccd1v21w0la9la8d263g/admin"
}