locals {
  install_config = yamlencode({
    additionalTrustBundlePolicy = "Proxyonly"
    apiVersion                  = "v1"
    baseDomain                  = local.base_infra.zone_name
    credentialsMode             = "Manual"
    compute = [
      {
        architecture   = "amd64"
        hyperthreading = "Enabled"
        name           = "worker"
        platform       = {}
        replicas       = 3
      },
    ]
    controlPlane = {
      architecture   = "amd64"
      hyperthreading = "Enabled"
      name           = "master"
      platform       = {}
      replicas       = 3
    }
    metadata = {
      creationTimestamp = null
      name              = random_pet.cluster_name.id
    }
    networking = {
      clusterNetwork = [
        {
          cidr       = "10.128.0.0/14"
          hostPrefix = 23
        },
      ]
      machineNetwork = [
        {
          cidr = "10.0.0.0/16"
        },
      ]
      networkType = "OVNKubernetes"
      serviceNetwork = [
        "172.30.0.0/16",
      ]
    }
    platform = {
      aws = {
        region = var.region
      }
    }
    publish    = "External"
    pullSecret = var.pull_secret
  })

  user_data = templatefile("${path.module}/scripts/user-data.tftpl", {
    cluster_name   = random_pet.cluster_name.id
    install_config = local.install_config
    pull_secret    = var.pull_secret
    region         = var.region
    s3_bucket_name = aws_s3_bucket.ignition_config.id
  })

  base_infra = data.terraform_remote_state.base_infra.outputs
}

data "terraform_remote_state" "base_infra" {
  backend = "remote"

  config = {
    organization = "hashicorp-support-eng"
    workspaces = {
      name = var.base_infra_workspace_name
    }
  }
}

resource "random_pet" "cluster_name" {
  length = 2
}
