locals {
  stack_prefix = "${var.system.id}-${var.env.id}"
  tags = {
    Env    = var.env.name
    System = var.system.name
    Stack  = local.stack_prefix
  }
}