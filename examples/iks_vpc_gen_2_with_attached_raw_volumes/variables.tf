variable "region" {
    type = string
    description = "(optional) describe your variable"
    default = "us-east"
}

variable "iks_cluster_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "resource_group" {
    type = string
    description = "(optional) describe your variable"
}

variable "capacity" {
    type = number
    description = "(optional) describe your variable"
    default = 100
}

variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of existing roks cluster"
  type        = string
}

variable "kube_config_path" {
  description = "Path to store k8s config file: ex `~/.kube/config`"
  type        = string
  default     = ".kubeconfig"
}
