resource "aws_iam_role" "codepipeline" {
  name               = "myCodePipelineRole"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.codepipeline_role.arn
  ]
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "codepipeline_role" {
  name   = "myCodePipelineRolePolicy"
  policy = data.aws_iam_policy_document.codepipeline_role.json
}

data "aws_iam_policy_document" "codepipeline_role" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
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
      "s3:GetObjectVersion"
    ]
    resources = ["${aws_s3_bucket.artifact.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "codebuild:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
}