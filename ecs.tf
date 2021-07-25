resource "aws_ecs_task_definition" "main" {
  family = var.task_family
  cpu    = var.task_cpu
  memory = var.task_memory

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_service.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = file(var.task_container_definitions_file)
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  desired_count   = var.service_desired_count
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    subnets         = [for nw in aws_subnet.private : nw.id]
    security_groups = [aws_security_group.ecs.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.service_name
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener_rule.ecs
  ]
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}