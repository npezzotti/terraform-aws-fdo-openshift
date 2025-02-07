output "redis_host" {
  description = "Redis hostname"
  value       = "${aws_elasticache_replication_group.tfe.primary_endpoint_address}:${aws_elasticache_replication_group.tfe.port}"
}

output "redis_password" {
  description = "Password to authenticate to Redis"
  value       = random_id.redis_password.id
}
