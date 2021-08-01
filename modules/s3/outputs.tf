output "buckets" {
  value = {
    logs = aws_s3_bucket.logs
  }
}