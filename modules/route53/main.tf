resource "aws_route53_record" "app_dns" {
  zone_id = var.parent_zone_id  # changed from var.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

output "full_domain" {
  value = "${var.subdomain}.${var.domain_name}"
}
