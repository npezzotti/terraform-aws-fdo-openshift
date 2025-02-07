resource "random_id" "redis_password" {
  byte_length = 16
}

resource "aws_security_group" "redis_ingress" {
  name        = "${var.prefix}-redis"
  description = "Allow traffic to redis from TFE"
  tags        = var.tags
  vpc_id      = var.vpc_id

  ingress {
    description     = "TFE ingress to redis"
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = var.security_groups
  }
}

resource "aws_elasticache_replication_group" "tfe" {
  description                = "External Redis for TFE."
  node_type                  = "cache.m4.large"
  num_cache_clusters         = 1
  replication_group_id       = "${var.prefix}-tfe"
  apply_immediately          = true
  at_rest_encryption_enabled = false
  auth_token                 = random_id.redis_password.id
  automatic_failover_enabled = false
  auto_minor_version_upgrade = true
  engine                     = "redis"
  engine_version             = "7.0"
  parameter_group_name       = "default.redis7"
  port                       = var.redis_port
  snapshot_retention_limit   = 0
  security_group_ids         = [aws_security_group.redis_ingress.id]
  subnet_group_name          = var.subnet_group_name
  transit_encryption_enabled = var.redis_use_password_auth
}
