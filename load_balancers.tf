resource "aws_lb" "external" {
  name               = "${module.installer.cluster_name}-external"
  ip_address_type    = "ipv4"
  subnets            = local.base_infra.vpc.public_subnets
  load_balancer_type = "network"
}

resource "aws_lb_listener" "external_api" {
  load_balancer_arn = aws_lb.external.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_api.arn
  }
}

resource "aws_lb_target_group" "external_api" {
  name                 = "${module.installer.cluster_name}-external-api"
  port                 = 6443
  vpc_id               = local.base_infra.vpc.vpc_id
  target_type          = "ip"
  protocol             = "TCP"
  deregistration_delay = "60"

  health_check {
    interval            = 10
    path                = "/readyz"
    port                = "6443"
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "internal" {
  name               = "${module.installer.cluster_name}-internal"
  ip_address_type    = "ipv4"
  internal           = true
  subnets            = local.base_infra.vpc.private_subnets
  load_balancer_type = "network"
}

resource "aws_lb_listener" "internal_api" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_api.arn
  }
}

resource "aws_lb_target_group" "internal_api" {
  name                 = "${module.installer.cluster_name}-internal-api"
  vpc_id               = local.base_infra.vpc.vpc_id
  port                 = 6443
  target_type          = "ip"
  protocol             = "TCP"
  deregistration_delay = "60"

  health_check {
    interval            = 10
    path                = "/readyz"
    port                = "6443"
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "internal_service" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 22623
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_service.arn
  }
}

resource "aws_lb_target_group" "internal_service" {
  name                 = "${module.installer.cluster_name}-int-service"
  vpc_id               = local.base_infra.vpc.vpc_id
  port                 = 22623
  target_type          = "ip"
  protocol             = "TCP"
  deregistration_delay = 60

  health_check {
    interval            = 10
    path                = "/healthz"
    port                = "22623"
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
