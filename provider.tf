terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "satellite"

  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "self" {}