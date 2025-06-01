variable "MONGO_URI" {
  description = "MongoDB Atlas connection URI"
  type        = string
  sensitive   = true
}
variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "ecs for grp4"
  type        = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}