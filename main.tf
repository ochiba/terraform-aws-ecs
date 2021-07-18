terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "satellite"
}