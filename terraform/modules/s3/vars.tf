variable "lab_version" {
  description = "The lab version"
  type        = string
  default     = "1.20.0"
}

variable "kms_key_arn" {
  description = "The ARN for the KMS key to encrypt the file system at rest"
  type        = string
}

variable "core_backups_retention" {
  description = "The retention policy for backups"
  type        = string
  default     = "NOBACKUP"
}

variable "core_backups_retention_pitr" {
  description = "The retention PITR policy for backups"
  type        = string
  default     = "NOBACKUP"
}

variable "lifecycle_rules" {
  description = "The lifecycle rules for the bucket"
  type = list(object({
    id = string
    filter = object({
      prefix = string
    })
    expiration = optional(list(object({
      days = number
    })))
    transitions = optional(list(object({
      storage_class = string
      days          = number
    })))
    noncurrent_version_expiration = optional(number)
  }))
  default = null
}
