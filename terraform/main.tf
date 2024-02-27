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
