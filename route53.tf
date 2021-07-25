variable "domain" {
  default = "poc1.ochiba.work"
}

data "aws_route53_zone" "main" {
  name         = var.domain
  private_zone = false
}

resource "aws_acm_certificate" "org" {
  domain_name       = "org.${var.domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "org_validation" {
  depends_on = [aws_acm_certificate.org]

  for_each = {
    for dvo in aws_acm_certificate.org.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  ttl             = 60
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  zone_id         = data.aws_route53_zone.main.id
}

resource "aws_acm_certificate_validation" "org" {
  certificate_arn         = aws_acm_certificate.org.arn
  validation_record_fqdns = [for record in aws_route53_record.org_validation : record.fqdn]
}

resource "aws_route53_record" "org" {
  type = "A"

  name    = "org.${var.domain}"
  zone_id = data.aws_route53_zone.main.id

  alias {
    name                   = aws_lb.ecs.dns_name
    zone_id                = aws_lb.ecs.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "ecs_https" {
  load_balancer_arn = aws_lb.ecs.arn

  certificate_arn = aws_acm_certificate.org.arn

  protocol = "HTTPS"
  port     = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.id
  }
}

resource "aws_lb_listener_rule" "http_to_https" {
  listener_arn = aws_lb_listener.ecs.arn

  priority = 99

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["org.${var.domain}"]
    }
  }
}

resource "aws_security_group_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}