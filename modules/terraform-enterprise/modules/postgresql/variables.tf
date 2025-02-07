variable "engine_version" {
  type = string
}

variable "db_instance_size" {
  type = string
}

variable "db_port" {
  type = number
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_group" {
  type = string
}

variable "cidr_blocks" {
  type = list(string)
}
