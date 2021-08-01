data "aws_iam_policy" "view_only_access" {
  name = "ViewOnlyAccess"
}

data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "codepipeline_full_access" {
  name = "AWSCodePipelineFullAccess"
}

resource "aws_iam_role" "my_admin" {
  name               = "${var.stack_prefix}-AdminRole"
  assume_role_policy = data.aws_iam_policy_document.my_switch_assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]
}

resource "aws_iam_role" "my_switch" {
  name               = "${var.stack_prefix}-SwitchRole"
  assume_role_policy = data.aws_iam_policy_document.my_switch_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.my_switch_role.arn,
    data.aws_iam_policy.codepipeline_full_access.arn
  ]
}

data "aws_iam_policy_document" "my_switch_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sso_account_id}:root"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = var.allow_src_ip
    }
  }
}

resource "aws_iam_policy" "my_switch_role" {
  name   = "${var.stack_prefix}-SwitchRole"
  policy = data.aws_iam_policy_document.my_switch_role.json
}

data "aws_iam_policy_document" "my_switch_role" {
  statement {
    sid    = "CloudFrontReadOnlyAccess"
    effect = "Allow"
    actions = [
      "acm:ListCertificates", 
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudfront:ListCloudFrontOriginAccessIdentities",
      "elasticloadbalancing:DescribeLoadBalancers",
      "iam:ListServerCertificates",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTopics",
      "waf:GetWebACL",
      "waf:ListWebACLs"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "CodeProductsAdminAccess"
    effect = "Allow"
    actions = [
      "codebuild:*",
      "codepipeline:*",
      # CodeCommit
      "codecommit:GetBranch",
      "codecommit:GetRepositoryTriggers",
      "codecommit:ListBranches",
      "codecommit:ListRepositories",
      "codecommit:PutRepositoryTriggers",
      "codecommit:GetReferences",
      # CodeDeploy
      "codedeploy:GetApplication",
      "codedeploy:BatchGetApplications",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:BatchGetDeploymentGroups",
      "codedeploy:ListApplications",
      "codedeploy:ListDeploymentGroups",
      # ECR
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      # ECS
      "ecs:ListClusters",
      "ecs:ListServices",
      # EC2
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      # Cloudwatch
      "cloudwatch:GetMetricStatistics",
      "events:DeleteRule",
      "events:DescribeRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:ListRuleNamesByTarget",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "logs:GetLogEvents",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "S3ListAllMyBuckets"
    effect = "Allow"
    actions = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    sid    = "S3Buckets"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_logs.arn
    ]
  }
  statement {
    sid    = "S3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${var.s3_bucket_logs.arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${var.self_account_id}:role/myCodeBuildRole",
      "arn:aws:iam::${var.self_account_id}:role/myCodePipelineRole"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:AttachRolePolicy",
      "iam:CreateRole"
    ]
    resources = [
      "arn:aws:iam::${var.self_account_id}:role/service-role/cwe-role-*",
      "arn:aws:iam::${var.self_account_id}:policy/service-role/start-pipeline-execution-*"
    ]
  }
}