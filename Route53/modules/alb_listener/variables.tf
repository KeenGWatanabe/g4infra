variable "alb_arn" {
  type        = string
  description = "ARN of the ALB"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the target group"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID attached to ALB"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listener"
}
