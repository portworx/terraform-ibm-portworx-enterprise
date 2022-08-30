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

variable "capacity" {
  type        = number
  description = "(optional) describe your variable"
  default     = 100
}
