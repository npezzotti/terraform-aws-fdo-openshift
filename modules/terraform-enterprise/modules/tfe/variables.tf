####################
# RDS DB           #
####################

variable "db_name" {
  type = string
}
variable "db_port" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_hostname" {
  type = string
}

variable "s3_bucket" {
  type = string
}

####################
# Object Storage   #
####################

variable "kms_key_id" {
  description = "The ID of the KMS key to use for TFE Object Storage"
  type        = string
}

####################
# Docker Registry  #
####################

variable "docker_registry" {
  type = string
}

variable "docker_registry_username" {
  type = string
}

variable "tfe_license" {
  type = string
}

variable "image" {
  type = string
}

variable "tag" {
  type = string
}

####################
# TFE Settings     #
####################

variable "tfe_hostname" {
  type = string
}

variable "node_count" {
  type = number
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "encryption_password" {
  type    = string
  default = "SUPERSECRET"
}

####################
# Helm             #
####################

variable "helm_chart_version" {
  type = string
}

variable "namespace" {
  type    = string
  default = "terraform-enterprise"
}

variable "tfe_iact_subnets" {
  type    = string
  default = ""
}

variable "service_annotations" {
  type    = map(string)
  default = {}
}

####################
# TLS              #
####################

variable "tls_cert" {
  type = string
}

variable "tls_ca_cert" {
  type = string
}

variable "tls_cert_key" {
  type = string
}

####################
# Redis            #
####################

variable "redis_host" {
  type = string
}

variable "redis_port" {
  type = string
}

variable "redis_password" {
  type = string
}

variable "redis_user" {
  type    = string
  default = ""
}

variable "redis_use_auth" {
  type    = bool
  default = true
}

variable "redis_use_tls" {
  type    = bool
  default = true
}

variable "role_arn" {
  type = string
}