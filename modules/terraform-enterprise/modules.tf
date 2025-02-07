module "object_storage" {
  source    = "./modules/object_storage"
  tags      = local.tags
  role_name = aws_iam_role.tfe_role.name
  prefix    = var.cluster_name
}

module "postgresql" {
  source                = "./modules/postgresql"
  engine_version        = "16.6"
  db_instance_size      = "db.t3.small"
  db_port               = "5432"
  prefix                = var.cluster_name
  tags                  = local.tags
  vpc_id                = var.vpc.vpc_id
  database_subnet_group = var.vpc.database_subnet_group
  cidr_blocks           = var.vpc.private_subnets_cidr_blocks
}

module "redis" {
  source                  = "./modules/redis"
  prefix                  = var.cluster_name
  subnet_group_name       = var.vpc.elasticache_subnet_group
  redis_use_password_auth = true
  redis_port              = "6379"
  vpc_id                  = var.vpc.vpc_id
  security_groups         = var.worker_security_groups
  tags                    = local.tags
}

module "tfe" {
  source = "./modules/tfe"

  docker_registry          = var.docker_registry
  docker_registry_username = var.docker_registry_username
  tag                      = var.tag
  image                    = var.image
  helm_chart_version       = var.helm_chart_version
  db_hostname              = module.postgresql.db_hostname
  db_name                  = module.postgresql.db_name
  db_password              = module.postgresql.db_password
  db_port                  = "5432"
  db_user                  = module.postgresql.db_user
  kms_key_id               = module.object_storage.kms_key_id
  node_count               = var.node_count
  redis_host               = module.redis.redis_host
  redis_password           = module.redis.redis_password
  redis_port               = "6379"
  redis_use_auth           = true
  redis_use_tls            = true
  s3_bucket                = module.object_storage.s3_bucket
  region                   = "us-east-1"

  service_annotations = {
    "service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"         = var.acm_wildcard_arn
    "service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol" = "ssl"
  }

  role_arn     = aws_iam_role.tfe_role.arn
  tfe_hostname = local.tfe_hostname
  tfe_license  = var.tfe_license
  tls_cert     = base64encode(tls_self_signed_cert.tfe.cert_pem)
  tls_ca_cert  = base64encode(tls_self_signed_cert.tfe.cert_pem)
  tls_cert_key = base64encode(tls_self_signed_cert.tfe.private_key_pem)
}