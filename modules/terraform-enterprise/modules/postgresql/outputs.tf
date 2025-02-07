output "db_name" {
  value = aws_db_instance.postgresql.db_name
}

output "db_user" {
  value = aws_db_instance.postgresql.username
}

output "db_password" {
  value = aws_db_instance.postgresql.password
}

output "db_hostname" {
  value = aws_db_instance.postgresql.endpoint
}
