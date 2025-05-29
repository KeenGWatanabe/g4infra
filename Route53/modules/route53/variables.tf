variable "subdomain" {
  type        = string
  description = "Subdomain to create, e.g., 'ce-grp-4'"
}

variable "parent_zone_id" {
  type        = string
  description = "The ID of the parent Route 53 hosted zone"
}

variable "alb_dns_name" {
  type        = string
  description = "The DNS name of the ALB to point to"
}
