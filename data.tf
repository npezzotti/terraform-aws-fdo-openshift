data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "terraform_remote_state" "base_infra" {
  backend = "remote"

  config = {
    organization = "hashicorp-support-eng"
    workspaces = {
      name = var.base_infra_workspace_name
    }
  }
}

data "aws_ami" "rhcos" {
  most_recent = true
  owners      = ["531415883065"]

  filter {
    name   = "image-id"
    values = ["ami-0e79bb8acc37d2696"]
  }

  filter {
    name   = "name"
    values = ["rhcos-4*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
