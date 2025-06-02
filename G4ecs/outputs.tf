output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}



# remarks
output "service_url" {
  value = aws_lb.app.dns_name
}