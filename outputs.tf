output "cluster_name" {
  value = module.installer.cluster_name
}

output "cluster_endpoint" {
  value = module.installer.kubeconfig
}

output "cluster_ca_certificate" {
  value = module.installer.kubeconfig
}

output "client_certificate" {
  value = module.installer.kubeconfig
}

output "client_key" {
  value = module.installer.kubeconfig
}

output "kubeconfig" {
  value     = module.installer.kubeconfig
  sensitive = true
}

output "kubeadmin_password" {
  value     = module.installer.kubeadmin_password
  sensitive = true
}

output "openshift_console_url" {
  value = "https://console-openshift-console.apps.${module.installer.cluster_name}.${data.aws_route53_zone.zone.name}"
}

output "tfe_url" {
  value = module.tfe.tfe_url
}
