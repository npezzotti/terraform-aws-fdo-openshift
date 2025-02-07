variable "region" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "acm_wildcard_arn" {
  type = string
}

variable "vpc" {
  description = "VPC object from base infra"
}

variable "cluster_name" {
  type = string
}

variable "worker_security_groups" {
  type = list(string)
}

variable "postgresql_version" {
  type    = string
  default = "16.0.0"
}

variable "docker_registry" {
  type        = string
  default     = "images.releases.hashicorp.com"
  description = "Appending of /hashicorp needed to registry URL for Docker to succesfully pull image via Terraform."
}

variable "docker_registry_username" {
  type    = string
  default = "terraform"
}

variable "tag" {
  type    = string
  default = "v202411-2"
}

variable "image" {
  type    = string
  default = "hashicorp/terraform-enterprise"
}

variable "helm_chart_version" {
  type    = string
  default = "1.3.4"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "tfe_license" {
  type = string
}

