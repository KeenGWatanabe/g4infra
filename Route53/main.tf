provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "parent" {
  name = "sctp-sandbox.com."
}

module "route53" {
  source          = "./modules/route53"
  subdomain       = "ce-grp-4"
  parent_zone_id  = data.aws_route53_zone.parent.zone_id
  alb_dns_name    = var.alb_dns_name
}

module "acm" {
  source   = "./modules/acm"
  domain   = "ce-grp-4.sctp-sandbox.com"
  zone_id  = data.aws_route53_zone.parent.zone_id
}

module "alb_listener" {
  source = "./modules/alb_listener"

  alb_arn            = var.alb_arn
  target_group_arn   = var.target_group_arn
  alb_security_group_id = var.alb_security_group_id
  certificate_arn    = module.acm.certificate_arn
}
