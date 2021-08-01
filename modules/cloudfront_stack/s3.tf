resource "aws_s3_bucket" "imgs" {
  bucket = "${var.stack_prefix}-imgs"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = var.s3_bucket_logs.id
    target_prefix = "s3-${var.stack_prefix}-imgs/"
  }

  tags = { Name = "${var.stack_prefix}-imgs" }
}

resource "aws_s3_bucket_public_access_block" "imgs" {
  bucket = aws_s3_bucket.imgs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "imgs" {
  bucket = aws_s3_bucket.imgs.id
  policy = data.aws_iam_policy_document.imgs.json
}

data "aws_iam_policy_document" "imgs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.imgs.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.main.iam_arn]
    }
  }
}