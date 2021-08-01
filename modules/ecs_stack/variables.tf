variable "stack_prefix" { type = string }
variable "region" { type = string }

variable "ecs" { type = map(any) }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

variable "vpc_id" { type = string }
variable "alb_subnets" { type = list(any) }
variable "ecs_subnets" { type = list(any) }
variable "s3_bucket_logs_id" { type = string }
variable "certificate_arn" { type = string }