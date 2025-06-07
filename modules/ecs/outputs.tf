output "alb_arn" {
  value = aws_lb.app.arn
}

output "app_tg_arn" {
  value = aws_lb_target_group.app_tg.arn
}

# modules/ecs/outputs.tf
output "alb_zone_id" {
  value = aws_lb.app.zone_id
}


output "alb_dns" {
  value = aws_lb.app.dns_name
}
