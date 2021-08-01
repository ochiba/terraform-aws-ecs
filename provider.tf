terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region  = var.region
  profile = var.aws.profile

  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "self" {}

provider "aws" {
  alias = "sso"

  region  = var.region
  profile = var.aws.sso_profile
}

data "aws_caller_identity" "sso" {
  provider = aws.sso
}