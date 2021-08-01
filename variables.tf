# Common
variable "aws" {
  default = {
    profile     = "satellite"
    sso_profile = "cocoa"
  }
}

variable "region" {
  default = "ap-northeast-1"
}
variable "system" {
  default = {
    id   = "wea"
    name = "White Eternity of Astraea"
  }
}
variable "env" {
  default = {
    id   = "dev"
    name = "develop"
  }
}

variable "allow_src_ip" {
  default = [
    "60.125.192.191"
  ]
}

# VPC
variable "vpc" {
  default = {
    cidr = "192.168.0.0/16"
  }
}

variable "subnets" {
  default = {
    public = [
      { az = "a", cidr = "192.168.0.0/24" },
      { az = "c", cidr = "192.168.1.0/24" }
    ]
    private = [
      { az = "a", cidr = "192.168.10.0/24" },
      { az = "c", cidr = "192.168.11.0/24" }
    ]
  }
}

variable "ecs_web" {
  default = {
    domain             = "poc1.ochiba.work"
    container_name     = "web"
    cpu                = 256
    memory             = 512
    memory_reservation = 128
    container_port     = 80
    host_port          = 80
    desired_count      = 1
    platform_version   = "1.4.0"
    health_check_path  = "/"
  }
}