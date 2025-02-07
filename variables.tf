variable "tags" {
  type    = map(string)
  default = {}
}

variable "base_infra_workspace_name" {
  type = string
}

variable "master_certificate_authorities" {
  type = string
}

variable "worker_certificate_authorities" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "infra_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "pull_secret" {
  type = string
}

variable "tfe_license" {
  type = string
}
