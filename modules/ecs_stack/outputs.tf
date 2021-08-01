output "alb" {
  value = {
    id     = aws_lb.ecs.dns_name
    domain = aws_route53_record.org.name
  }  
}