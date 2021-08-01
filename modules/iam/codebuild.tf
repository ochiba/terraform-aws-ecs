resource "aws_s3_bucket" "artifact" {
  bucket = "codepipeline-apne1-20210801"
  acl    = "private"
}

resource "aws_iam_role" "codebuild" {
  name               = "myCodeBuildRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.codebuild_role.arn
  ]
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "codebuild_role" {
  name   = "myCodeBuildRolePolicy"
  policy = data.aws_iam_policy_document.codebuild_role.json
}

data "aws_iam_policy_document" "codebuild_role" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:ListBranches",
      "codecommit:ListRepositories",
      "codecommit:BatchGetRepositories",
      "codecommit:Get*",
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifact.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = ["${aws_s3_bucket.artifact.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}
