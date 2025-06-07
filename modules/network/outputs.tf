output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}

output "alb_sg_id" {
  value = aws_security_group.lb.id
}

output "lb_sg_id" {
  value = aws_security_group.lb.id
}

output "lb_security_group_id" {
  value = aws_security_group.lb.id
}
