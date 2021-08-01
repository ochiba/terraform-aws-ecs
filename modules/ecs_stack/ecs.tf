resource "aws_ecs_cluster" "main" {
  name = local.ecs_vars.cluster_name
}

resource "aws_ecs_task_definition" "main" {
  family = local.ecs_vars.task_name
  cpu    = local.ecs_vars.cpu
  memory = local.ecs_vars.memory

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = templatefile(
    "files/container_definitions/default.json.tpl",
    local.ecs_vars
  )
}

resource "aws_ecs_service" "main" {
  name             = local.ecs_vars.service_name
  cluster          = aws_ecs_cluster.main.id
  launch_type      = "FARGATE"
  desired_count    = var.ecs.desired_count
  task_definition  = aws_ecs_task_definition.main.arn
  platform_version = var.ecs.platform_version

  health_check_grace_period_seconds = 15

  network_configuration {
    subnets         = [for nw in var.ecs_subnets : nw.id]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = local.ecs_vars.container_name
    container_port   = local.ecs_vars.container_port
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}