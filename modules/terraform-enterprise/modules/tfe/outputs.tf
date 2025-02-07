output "tfe_namespace_id" {
  description = "The ID of the Terraform Enterprise namespace"
  value       = kubernetes_namespace.tfe.id
}
