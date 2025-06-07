resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = element(aws_acm_certificate.cert.domain_validation_options[*].resource_record_name, 0)
  type    = element(aws_acm_certificate.cert.domain_validation_options[*].resource_record_type, 0)
  zone_id = var.zone_id
  ttl     = 60
  records = [element(aws_acm_certificate.cert.domain_validation_options[*].resource_record_value, 0)]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  depends_on = [aws_acm_certificate_validation.cert]
}


