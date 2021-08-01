# for ECS Service
resource "aws_iam_role" "ecs_service" {
  name               = "${var.stack_prefix}-ECSServiceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.ecs_service_role.arn
  ]
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

resource "aws_iam_policy" "ecs_service_role" {
  name   = "${var.stack_prefix}-ECSServiceRolePolicy"
  policy = data.aws_iam_policy_document.ecs_service_role.json
}

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