variable "domain_name" {
  description = "The root domain name (e.g. sctp-sandbox.com)"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to create (e.g. ce-grp4)"
  type        = string
}

variable "parent_zone_id" {
  description = "Zone ID of the root domain"
  type        = string
}

variable "alb_dns" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}
