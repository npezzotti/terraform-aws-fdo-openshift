data "aws_route53_zone" "zone" {
  name = local.base_infra.zone_name
}

resource "aws_route53_zone" "internal" {
  name          = join(".", [module.installer.cluster_name, data.aws_route53_zone.zone.name])
  force_destroy = true

  vpc {
    vpc_id     = local.base_infra.vpc.vpc_id
    vpc_region = "us-east-1"
  }

  tags = {
    Name                                                 = join("-", [module.installer.infra_id, "int"])
    "kubernetes.io/cluster/${module.installer.infra_id}" = "owned"
  }
}

resource "aws_route53_record" "external_api" {
  zone_id = data.aws_route53_zone.zone.id
  name    = join(".", ["api", module.installer.cluster_name, data.aws_route53_zone.zone.name])
  type    = "A"

  alias {
    name                   = aws_lb.external.dns_name
    zone_id                = aws_lb.external.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "internal_api_internal" {
  zone_id = aws_route53_zone.internal.id
  name    = join(".", ["api", aws_route53_zone.internal.name])
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "internal_api" {
  zone_id = aws_route53_zone.internal.id
  name    = join(".", ["api-int", aws_route53_zone.internal.name])
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}
