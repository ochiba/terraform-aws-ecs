resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

# IAM Role for ECS Service
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect    = "Allow"
    actions   = var.iam_policy_actions_ecs_service_role_default
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
  name               = "myECSServiceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_service_role.arn
  ]
}

# IAM Role for ECS Task
data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect    = "Allow"
    actions   = var.iam_policy_actions_ecs_service_role_default
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
  name               = "myECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_task_role.arn
  ]
}

# Security Group for ECS
resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allow HTTP for ECS"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs"
  }
}

resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [aws_vpc.main.cidr_block]
}