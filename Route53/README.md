
# Terraform Setup for Route53 Subdomain with HTTPS
This project uses Terraform to automate the creation of an AWS Route 53 subdomain with HTTPS support. The HTTPS is enabled by provisioning an ACM certificate and an Application Load Balancer (ALB) that routes traffic to the ECS cluster.

I have tested the terraform setup. The app can be accessed from: https://ce-grp-4.sctp-sandbox.com

---

## Overview

The Terraform configuration provisions the following AWS resources:
- **Route 53** Hosted Zone (existing domain) and subdomain DNS record
- **ACM** Certificate for the domain/subdomain to enable HTTPS

The following components assumed already created.
- **ALB (Application Load Balancer)** with HTTPS listener
- **ECS cluster** and services 
- **ECR repository** for Docker images

---


## terraform.tfvars 
Change content in terraform.tfvars accordingly.

- domain_name          = "sctp-sandbox.com"
- subdomain            = "ce-grp-4"
- zone_id              = "us-east-1"
- alb_arn              = "arn:aws:elasticloadbalancing:us-east-1:255945442255:loadbalancer/app/lbr-for-nginx/6c2db03d69f914c1" # Change to actual ce-grp4 alb-arn
- parent_zone_id       = "us-east-1"
- alb_dns_name         = "lbr-for-nginx-1808883278.us-east-1.elb.amazonaws.com" # Change to actual ce-grp-4 alb dns
- alb_zone_id          = "us-east-1"

- target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:255945442255:targetgroup/nginx-tg/e28087c569844a20" # Change to actual target group arn
- alb_security_group_id = "sg-0ae911e9e2e139779" # Change to actual alb sg


---

![Screenshot 2025-05-26 230721](https://github.com/user-attachments/assets/5de1f742-cc24-4836-9b7c-91e7e69d0bdd)


Note:
To solve the Error: modifying ELBv2 Listener (...................

Run the following in  CLI:

aws elbv2 delete-listener --listener-arn arn:aws:elasticloadbalancing:us-east-1:255945442255:listener/app/ce-grp-47fcb8e53-app-lb/c2c8babf148991f8/48910ac4e4a131e7

Then run: terraform apply
