resource "aws_db_instance" "postgresql" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = var.db_instance_size
  password          = "hashicorp"
  username          = "hashicorp"

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  backup_retention_period     = 0
  db_subnet_group_name        = var.database_subnet_group
  delete_automated_backups    = true
  deletion_protection         = false
  engine_version              = var.engine_version
  identifier_prefix           = "tfe-${var.prefix}"
  max_allocated_storage       = 0
  multi_az                    = true
  db_name                     = "hashicorp"
  port                        = var.db_port
  publicly_accessible         = false
  skip_final_snapshot         = true
  storage_encrypted           = true
  storage_type                = "gp3"
  tags                        = var.tags
  vpc_security_group_ids      = [aws_security_group.postgresql.id]
}

resource "aws_security_group" "postgresql" {
  description = "The security group of the PostgreSQL deployment for TFE."
  name        = "tfe-${var.prefix}-postgresql"
  tags        = var.tags
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    protocol    = "tcp"
    to_port     = var.db_port
    cidr_blocks = var.cidr_blocks
    description = "Allow the ingress of PostgreSQL traffic from the private subnets."
  }
}
