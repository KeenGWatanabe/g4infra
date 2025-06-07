resource "aws_wafv2_web_acl" "tasklister_acl" {
  name        = "tasklister-waf"
  description = "WAF for Tasklister ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "tasklisterWAF"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }
}

resource "aws_wafv2_web_acl_association" "tasklister_waf_assoc" {
  resource_arn = aws_lb.app.arn
  web_acl_arn  = aws_wafv2_web_acl.tasklister_acl.arn
}
