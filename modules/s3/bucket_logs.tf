data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.stack_prefix}-logs"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ_ACP", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }

  grant {
    # awslogsdelivery account for CloudFront
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  tags = { Name = "${var.stack_prefix}-logs" }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "logs" {
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.logs.arn}/lb/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.logs.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      aws_s3_bucket.logs.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}