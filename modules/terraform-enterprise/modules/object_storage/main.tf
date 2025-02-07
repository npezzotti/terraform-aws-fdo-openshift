resource "aws_kms_key" "main" {
  deletion_window_in_days = 7
  description             = "The key of the storage bucket for TFE ${var.prefix}."
  tags                    = var.tags
}

resource "aws_s3_bucket" "main" {
  bucket_prefix = "${var.prefix}-storage"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"

      kms_master_key_id = aws_kms_key.main.id
    }
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    sid    = "AllowKMSEncryptDecrypt"

    actions = [
      "kms:*",
    ]

    resources = [
      aws_kms_key.main.arn,
    ]
  }

  statement {
    effect = "Allow"
    sid    = "AllowS3"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "main" {
  policy      = data.aws_iam_policy_document.main.json
  description = "The policy of the storage deployment for TFE."
  name        = "tfe-${var.prefix}-storage"
}

resource "aws_iam_role_policy_attachment" "main" {
  policy_arn = aws_iam_policy.main.arn
  role       = var.role_name
}
