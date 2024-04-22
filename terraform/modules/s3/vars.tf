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
