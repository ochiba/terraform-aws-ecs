resource "aws_cloudwatch_log_group" "ecs" {
  name = local.ecs_vars.log_group

  tags = { Name = local.ecs_vars.log_group }
}