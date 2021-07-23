resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

# IAM Role for ECS Service
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect = "Allow"
    actions = [
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
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_service_role" {
  name   = "myECSServiceRolePolicy"
  policy = data.aws_iam_policy_document.ecs_service_role.json
}

data "aws_iam_policy_document" "ecs_service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  name = "myECSServiceRole"
  assume_role_policy  = data.aws_iam_policy_document.ecs_service_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_service_role.arn
  ]
}

# IAM Role for ECS Task
data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect = "Allow"
    actions = [
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
    resources = ["*"]
  }  
}

resource "aws_iam_policy" "ecs_task_role" {
  name   = "myECSTaskRolePolicy"
  policy = data.aws_iam_policy_document.ecs_task_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "myECSTaskRole"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_task_role.arn
  ]
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-sg-ecs"
  description = "SG for ${var.name} ecs"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg-ecs"
  }
}

resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [var.vpc.cidr]
}

resource "aws_ecs_task_definition" "main" {
  family = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_service
  task_role_arn      = aws_iam_role.ecs_task

  cpu = 256
  memory = 512

  container_definitions = file("ecs/container_definitions.json")
}

resource "aws_ecs_cluster" "main" {
  name = var.name
}

resource "aws_ecs_service" "main" {
  name = var.name
  depends_on = [
    aws_lb_listener_rule.ecs
  ]
  cluster = aws_ecs_cluster.main.name
  launch_type = "FARGATE"
  desired_count = 1
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    subnets = [ for x in aws_subnet.private : x.id ]
    security_groups = [ aws_security_group.ecs.id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name = "nginx"
    container_port = 80
  }
}