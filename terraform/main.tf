locals {
  run_id = "prod"
}

module "kms" {
  source = "./modules/kms"

  kms_key_alias       = join("", [var.kms_key_alias, local.run_id])
  kms_key_description = "Key for EFS"
}

module "s3" {
  source = "./modules/s3"

  kms_key_arn            = module.kms.kms_key_arn
  core_backups_retention = "NOBACKUP"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = module.s3.bucket_id

  rule {
    id     = "log"
    status = "Enabled"

    filter {
      and {
        prefix = "log/"
        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 10
    }
  }
}
