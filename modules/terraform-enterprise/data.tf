data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zone" {
  name = var.zone_name
}

data "aws_iam_openid_connect_provider" "openshift" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.cluster_name}-oidc.s3.us-east-1.amazonaws.com"
}

data "kubernetes_service" "tfe" {
  metadata {
    name      = module.tfe.tfe_namespace_id
    namespace = module.tfe.tfe_namespace_id
  }

  depends_on = [
    module.tfe
  ]
}
