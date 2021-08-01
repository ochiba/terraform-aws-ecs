# for ECS Task
resource "aws_iam_role" "ecs_task" {
  name               = "${var.stack_prefix}-ECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_task_role.arn
  ]
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

resource "aws_iam_policy" "ecs_task_role" {
  name   = "${var.stack_prefix}-ECSTaskRolePolicy"
  policy = data.aws_iam_policy_document.ecs_task_role.json
}

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