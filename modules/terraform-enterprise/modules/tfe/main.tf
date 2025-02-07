locals {
  helm_values = {
    replicaCount = 1

    "tls.certData"   = var.tls_cert
    "tls.caCertData" = var.tls_ca_cert

    "image.repository" = var.docker_registry
    "image.name"       = var.image
    "image.tag"        = var.tag

    "resources.requests.cpu"    = ".5"
    "resources.requests.memory" = "1000Mi"

    "openshift.enabled"                                         = true
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = var.role_arn

    "env.variables.TFE_HOSTNAME"                                            = var.tfe_hostname
    "env.variables.TFE_IACT_SUBNETS"                                        = var.tfe_iact_subnets
    "env.variables.TFE_DATABASE_HOST"                                       = var.db_hostname
    "env.variables.TFE_DATABASE_NAME"                                       = var.db_name
    "env.variables.TFE_DATABASE_USER"                                       = var.db_user
    "env.variables.TFE_DATABASE_PARAMETERS"                                 = "sslmode=require"
    "env.variables.TFE_OBJECT_STORAGE_TYPE"                                 = "s3"
    "env.variables.TFE_OBJECT_STORAGE_S3_BUCKET"                            = var.s3_bucket
    "env.variables.TFE_OBJECT_STORAGE_S3_REGION"                            = var.region
    "env.variables.TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION"            = "aws:kms"
    "env.variables.TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION_KMS_KEY_ID" = var.kms_key_id
    "env.variables.TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE"              = "true"
    "env.variables.TFE_REDIS_HOST"                                          = var.redis_host
    "env.variables.TFE_REDIS_USE_AUTH"                                      = "true"
    "env.variables.TFE_REDIS_USE_TLS"                                       = "true"
  }

  helm_secret_values = {
    "tls.keyData"                           = var.tls_cert_key
    "env.variables.TFE_DATABASE_PASSWORD"   = var.db_password
    "env.variables.TFE_ENCRYPTION_PASSWORD" = var.encryption_password
    "env.variables.TFE_LICENSE"             = var.tfe_license
    "env.variables.TFE_REDIS_PASSWORD"      = var.redis_password
  }

  service_annotations = { for k, v in var.service_annotations : "service.annotations.${k}" => v }

  values = merge(local.helm_values, local.service_annotations)
}

resource "kubernetes_namespace" "tfe" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_secret" "docker_registry" {
  metadata {
    name      = "terraform-enterprise"
    namespace = kubernetes_namespace.tfe.id
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.docker_registry}" = {
          "username" = var.docker_registry_username
          "password" = var.tfe_license
          "auth"     = base64encode("${var.docker_registry_username}:${var.tfe_license}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "helm_release" "tfe" {
  name       = "terraform-enterprise"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "terraform-enterprise"
  version    = var.helm_chart_version
  namespace  = kubernetes_namespace.tfe.id

  dynamic "set" {
    for_each = local.values

    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = local.helm_secret_values

    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }
}
