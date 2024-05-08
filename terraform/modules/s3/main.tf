locals {
  s3 = {
    bucket_name_prefix = "jp-"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = local.s3.bucket_name_prefix

  tags = {
    org         = "cloudacademy"
    environment = "dev"
    backup      = var.core_backups_retention
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  count  = var.lifecycle_rules == null ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules == null ? [] : var.lifecycle_rules

    content {
      id     = rule.value.id
      status = "Enabled"

      filter {
        prefix = rule.value.filter.prefix
      }

      expiration {
        days = rule.value.expiration[0].days
      }

      dynamic "transition" {
        for_each = rule.value.transitions == null ? [] : rule.value.transitions

        content {
          storage_class = transition.value.storage_class
          days          = transition.value.days
        }
      }
    }
  }
}
