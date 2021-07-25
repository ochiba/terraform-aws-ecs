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

variable "iam_policy_actions_ecs_service_role_default" {
  default = [
    # Rules which allow ECS to attach network interfaces to instances
    # on your behalf in order for awsvpc networking mode to work right
    "ec2:AttachNetworkInterface",
    "ec2:CreateNetworkInterface",
    "ec2:CreateNetworkInterfacePermission",
    "ec2:DeleteNetworkInterface",
    "ec2:DeleteNetworkInterfacePermission",
    "ec2:Describe*",
    "ec2:DetachNetworkInterface",
    # Rules which allow ECS to update load balancers on your behalf
    # with the information sabout how to send traffic to your containers
    "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
    "elasticloadbalancing:DeregisterTargets",
    "elasticloadbalancing:Describe*",
    "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
    "elasticloadbalancing:RegisterTargets",
    # Rules which allow ECS to run tasks that have IAM roles assigned to them.
    "iam:PassRole",
    # Rules that let ECS interact with container images.
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    # Rules that let ECS create and push logs to CloudWatch.
    "logs:DescribeLogStreams",
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"
  ]
}

variable "iam_policy_actions_ecs_task_role_default" {
  default = [
    # Allow the ECS Tasks to download images from ECR
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    # Allow the ECS tasks to upload logs to CloudWatch
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"
  ]
}


variable "task_family" {
  default = "web-task1"
}
variable "task_cpu" {
  default = 256
}
variable "task_memory" {
  default = 512
}
variable "task_container_definitions_file" {
  default = "ecs/container_definitions.json"
}

variable "cluster_name" {
  default = "web-cluster1"
}

variable "service_name" {
  default = "web-service1"
}
variable "service_desired_count" {
  default = 1
}
