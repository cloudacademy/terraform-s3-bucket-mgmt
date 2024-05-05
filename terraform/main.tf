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

  lifecycle_rules = [
    {
      id : "archive-logs"
      filter = {
        prefix = "logs/"
      }
      expiration = [{
        days : 500
      }]
      transitions : [
        {
          storage_class : "STANDARD_IA",
          days : 30
        },
        {
          storage_class : "INTELLIGENT_TIERING",
          days : 60
        },
        {
          storage_class : "GLACIER_IR",
          days : 120
        },
        {
          storage_class : "DEEP_ARCHIVE",
          days : 365
        }
      ]
    }
  ]
}
