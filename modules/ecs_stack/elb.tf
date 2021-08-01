resource "aws_lb" "ecs" {
  name               = "${var.stack_prefix}-alb-${var.ecs.container_name}"
  internal           = false
  load_balancer_type = "application"

  subnets         = [for nw in var.alb_subnets : nw.id]
  security_groups = [aws_security_group.alb.id]

  access_logs {
    bucket  = var.s3_bucket_logs_id
    prefix  = "lb"
    enabled = true
  }

  tags = { Name = "${var.stack_prefix}-alb-${var.ecs.container_name}" }
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn

  port            = 443
  protocol        = "HTTPS"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_lb_target_group" "ecs" {
  name   = "${var.stack_prefix}-tg-${var.ecs.container_name}"
  vpc_id = var.vpc_id

  port        = var.ecs.host_port
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = var.ecs.host_port
    path = var.ecs.health_check_path
  }

  deregistration_delay = 60
}