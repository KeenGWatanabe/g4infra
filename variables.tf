variable "vpc_id" {
  description = "The ID of the VPC to deploy ECS and ALB resources into"
}

variable "public_subnets" {
  description = "List of public subnet IDs for ECS and ALB"
  type        = list(string)
}

variable "lb_security_group_id" {
  description = "Security group ID attached to the ALB"
}
