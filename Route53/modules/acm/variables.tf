variable "domain" {
  type        = string
  description = "The domain name to request a certificate for"
}

variable "zone_id" {
  type        = string
  description = "The Route 53 hosted zone ID for DNS validation"
}
