resource "aws_s3_bucket" "ignition_config" {
  bucket        = "${random_pet.cluster_name.id}-ign-configs"
  force_destroy = true
}
