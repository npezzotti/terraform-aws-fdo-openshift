variable "prefix" {
  description = "Prefix for redis"
  type        = string
}

variable "subnet_group_name" {
  description = "Name of the cache subnet group to be used for the replication group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "tags" {
  description = "Tags to add to Redis resources"
  type        = map(any)
}

variable "security_groups" {
  description = "The security groups to allow ingress from."
  type        = list
}

variable "redis_use_password_auth" {
  description = "Whether or not to use password authentication for Redis"
  type        = bool
}

variable "redis_port" {
  description = "The port to use for Redis."
  type        = number
}
