locals {
  tags         = {}
  tfe_hostname = "${var.cluster_name}.${var.zone_name}"
}

resource "aws_iam_role" "tfe_role" {
  name               = "tfe-role"
  assume_role_policy = data.aws_iam_policy_document.tfe.json
}

data "aws_iam_policy_document" "tfe" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_iam_openid_connect_provider.openshift.url, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.openshift.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.openshift.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${module.tfe.tfe_namespace_id}:${module.tfe.tfe_namespace_id}"]
    }
  }
}

resource "tls_private_key" "tfe" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "tfe" {
  private_key_pem = tls_private_key.tfe.private_key_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [local.tfe_hostname]

  subject {
    common_name  = local.tfe_hostname
    organization = "HashiCorp Inc."
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.tfe_hostname
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service.tfe.status.0.load_balancer.0.ingress.0.hostname]
}
