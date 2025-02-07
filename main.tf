locals {
  host                   = yamldecode(module.installer.kubeconfig).clusters[0].cluster.server
  cluster_ca_certificate = yamldecode(module.installer.kubeconfig).clusters[0].cluster.certificate-authority-data
  client_certificate     = yamldecode(module.installer.kubeconfig).users[0].user.client-certificate-data
  client_key             = yamldecode(module.installer.kubeconfig).users[0].user.client-key-data
  # user_email is the users email address as gathered from the aws_caller_identity data source
  # the email is prefixed with a string of text followed by a semicolon, so we want to strip that away
  user_email   = replace(data.aws_caller_identity.current.user_id, "/^.*:/", "")
  tfe_hostname = "${module.installer.cluster_name}.${local.base_infra.zone_name}"
  base_infra   = data.terraform_remote_state.base_infra.outputs

  tags = merge({
    OwnedBy = local.user_email
  }, var.tags)
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

module "installer" {
  source = "./modules/installer"

  base_infra_workspace_name = var.base_infra_workspace_name
  pull_secret               = var.pull_secret
  region                    = local.base_infra.region
}

module "tfe" {
  source = "./modules/terraform-enterprise"

  region                 = local.base_infra.region
  vpc                    = local.base_infra.vpc
  zone_name              = local.base_infra.zone_name
  acm_wildcard_arn       = local.base_infra.acm_wildcard_arn
  cluster_name           = module.installer.cluster_name
  worker_security_groups = [aws_security_group.worker.id]
  tfe_license            = var.tfe_license
}
