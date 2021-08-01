variable "stack_prefix" { type = string }
variable "region" { type = string }

variable "vpc" { type = map(any) }
variable "subnets" { type = map(any) }