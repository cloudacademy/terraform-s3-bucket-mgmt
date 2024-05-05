# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "kms_key_arn" {
  description = "The ARN for the KMS key to encrypt the file system at rest"
  type        = string
}

variable "core_backups_retention" {
  description = "The retention policy for backups"
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
    expiration = list(object({
      days = number
    }))
    transitions = optional(list(object({
      storage_class = string
      days          = number
    })))
  }))
  default = null
}
