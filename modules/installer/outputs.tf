output "s3_bucket_name" {
  value = aws_s3_bucket.ignition_config.id
}

output "cluster_name" {
  value = random_pet.cluster_name.id
}

output "infra_id" {
  value = data.external.cluster_outputs.result.infra_id
}

output "kubeadmin_password" {
  value     = data.external.cluster_outputs.result.kubeadmin_password
  sensitive = true
}

output "kubeconfig" {
  value     = data.external.cluster_outputs.result.kubeconfig
  sensitive = true
}
