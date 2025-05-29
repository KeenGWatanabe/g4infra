variable "domain_name" {
  type        = string
  description = "Base domain name (e.g. sctp-sandbox.com)"
}

variable "subdomain" {
  type        = string
  description = "Subdomain to create (e.g. ce-grp4)"
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone ID"
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB"
}

variable "alb_zone_id" {
  type        = string
  description = "Hosted zone ID for the ALB (for Route 53 ALIAS)"
}

variable "parent_zone_id" {
  type        = string
  description = "Parent hosted zone ID (used for subdomain records)"
}


variable "target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}
