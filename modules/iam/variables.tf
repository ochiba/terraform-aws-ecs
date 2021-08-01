variable "stack_prefix" { type = string }

variable "self_account_id" { type = string }
variable "sso_account_id" { type = string }
variable "allow_src_ip" { type =  list }
variable "s3_bucket_logs" {}