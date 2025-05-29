resource "aws_route53_record" "subdomain" {
  zone_id = var.parent_zone_id
  name    = "${var.subdomain}.sctp-sandbox.com"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = "Z35SXDOTRQ7X7K"  # Hosted zone ID for us-east-1 ALB (static)
    evaluate_target_health = true
  }
}
