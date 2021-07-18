# Common
variable "name" {
  default = "ecs"
}

# VPC
variable "vpc" {
  default = {
    name = "ecs"
    cidr = "192.168.0.0/16"
  }
}

variable "subnets_public" {
  default = {
    public-a01 = {
      availability_zone = "ap-northeast-1a"
      cidr              = "192.168.0.0/24"
    }
    public-c01 = {
      availability_zone = "ap-northeast-1c"
      cidr              = "192.168.1.0/24"
    }
  }
}

variable "subnets_private" {
  default = {
    private-a01 = {
      availability_zone = "ap-northeast-1a"
      cidr              = "192.168.10.0/24"
    }
    private-c01 = {
      availability_zone = "ap-northeast-1c"
      cidr              = "192.168.11.0/24"
    }
  }
}