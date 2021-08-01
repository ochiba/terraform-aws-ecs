resource "aws_cloudfront_distribution" "main" {
  enabled = true

  default_root_object = "index.html"

  logging_config {
    bucket          = var.s3_bucket_logs.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/"
  }

  origin {
    domain_name = aws_s3_bucket.imgs.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.imgs.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  origin {
    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = var.elb_domain
    origin_id   = var.elb_id
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = false

    forwarded_values {
      cookies {
        forward = "none"
      }
      headers      = ["*"]
      query_string = true
    }

    default_ttl = 3600
    min_ttl     = 0
    max_ttl     = 86400

    target_origin_id       = var.elb_id
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = false

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
    }

    default_ttl = 3600
    min_ttl     = 0
    max_ttl     = 86400

    path_pattern           = "/imgs/*"
    target_origin_id       = aws_s3_bucket.imgs.id
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"
  }

  web_acl_id = aws_waf_web_acl.allow_only_company.id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "main" {}