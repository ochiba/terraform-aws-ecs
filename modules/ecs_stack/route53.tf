data "aws_route53_zone" "main" {
  name         = var.ecs.domain
  private_zone = false
}

resource "aws_route53_record" "org" {
  type = "A"

  name    = "org-${var.ecs.container_name}.${var.ecs.domain}"
  zone_id = data.aws_route53_zone.main.id

  alias {
    name                   = aws_lb.ecs.dns_name
    zone_id                = aws_lb.ecs.zone_id
    evaluate_target_health = true
  }
}