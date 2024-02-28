terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

#====================================

locals {
  s3 = {
    bucket_name_prefix = "cloudacademy"
  }
}

#====================================

resource "aws_s3_bucket" "bucket1" {
  bucket_prefix = local.s3.bucket_name_prefix

  tags = {
    org         = "cloudacademy"
    environment = "dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket1" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket1,
    aws_s3_bucket_public_access_block.bucket1
  ]

  bucket = aws_s3_bucket.bucket1.id
  acl    = "public-read"
}
