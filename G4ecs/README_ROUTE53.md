To modify the routing to use your existing DNS (like Route53) for the ECS ALB setup, you'll need to:

1. **Ensure your ACM certificate is properly validated** using DNS validation with your existing Route53 hosted zone
2. **Create Route53 records** pointing to your ALB
3. **Update your ALB listener** to use this certificate

Here's how to modify your configuration:

### 1. Update ACM Certificate with DNS Validation

```hcl
resource "aws_acm_certificate" "app" {
  domain_name       = "ce-grp-4.sctp-sandbox.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Automatically create Route53 validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id  # Your existing hosted zone
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```

### 2. Add Route53 Record for Your ALB

```hcl
data "aws_route53_zone" "selected" {
  name         = "sctp-sandbox.com."  # Your existing domain
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "ce-grp-4.sctp-sandbox.com"
  type    = "A"

  alias {
    name                   = aws_lb.your_lb.dns_name
    zone_id                = aws_lb.your_lb.zone_id
    evaluate_target_health = true
  }
}
```

### 3. Update Your ALB Listener to Use the Certificate

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.your_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.app.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.your_tg.arn
  }
}
```

### Key Points:
1. Make sure you have access to the Route53 hosted zone for `sctp-sandbox.com`
2. The certificate must be in the same region as your ALB
3. DNS propagation might take a few minutes after creation
4. If you're using a subdomain (like `ce-grp-4.sctp-sandbox.com`), ensure the parent domain (`sctp-sandbox.com`) is properly configured in Route53

### For Your ECS Setup:
In your `g4infra` repository, you'll need to:
1. Add these Route53 resources to your Terraform configuration
2. Ensure the ALB outputs its DNS name and zone ID (if not already doing so)
3. Verify the security groups allow HTTPS traffic (port 443)

Would you like me to help you integrate this with your specific ECS ALB configuration from the g4infra repository?