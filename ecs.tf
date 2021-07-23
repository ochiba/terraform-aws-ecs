resource "aws_security_group" "ecs" {
  name        = "${var.name}-sg-ecs"
  description = "SG for ${var.name} ecs"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg-ecs"
  }
}

resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [var.vpc.cidr]
}

resource "aws_ecs_task_definition" "main" {
  family = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  cpu = 256
  memory = 512

  container_definitions = file("ecs/container_definitions.json")
}

resource "aws_ecs_cluster" "main" {
  name = var.name
}

resource "aws_ecs_service" "main" {
  name = var.name
  depends_on = [
    aws_lb_listener_rule.ecs
  ]
  cluster = aws_ecs_cluster.main.name
  launch_type = "FARGATE"
  desired_count = 1
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    subnets = [ for x in aws_subnet.private : x.id ]
    security_groups = [ aws_security_group.ecs.id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name = "nginx"
    container_port = 80
  }
}