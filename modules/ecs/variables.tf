variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "image_url" {
  description = "Docker image URL"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_sg_id" {
  description = "ALB security group ID"
  type        = string
}

variable "lb_security_group_id" {
  description = "Load balancer security group ID"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for ECS"
  type        = list(string)
}
