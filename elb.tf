resource "aws_security_group" "alb" {
  name        = "${var.name}-sg-alb"
  description = "SG for ${var.name} alb"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg-alb"
  }
}

resource "aws_security_group_rule" "alb" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "ecs" {
  load_balancer_type = "application"
  name               = "${var.name}-alb"

  security_groups = [aws_security_group.alb.id]
  subnets         = [for x in aws_subnet.public : x.id]
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "ecs" {
  name = var.name
  vpc_id = aws_vpc.main.id

  port = 80
  protocol = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener_rule" "ecs" {
  listener_arn = aws_lb_listener.ecs.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs.id
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}