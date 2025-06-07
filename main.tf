terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

data "aws_availability_zones" "available" {}

# Network module
module "network" {
  source                = "./modules/network"
  vpc_cidr              = "10.0.0.0/16"
  azs                   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  domain_name           = "sctp-sandbox.com"
}



# ECR module
module "ecr" {
  source     = "./modules/ecr"
  aws_region = var.aws_region
}

# ECS module
module "ecs" {
  source              = "./modules/ecs"
  cluster_name        = "node-app-cluster"
  image_url           = module.ecr.image_url
  subnets             = module.network.public_subnets
  public_subnets      = module.network.public_subnets
  vpc_id              = module.network.vpc_id  
  alb_sg_id           = module.network.alb_sg_id
  lb_security_group_id = module.network.lb_sg_id

}


# ACM module
module "acm" {
  source            = "./modules/acm"
  domain_name       = "sctp-sandbox.com"
  subdomain         = "ce-grp4"
  zone_id           = module.network.zone_id
  alb_arn           = module.ecs.alb_arn
  target_group_arn  = module.ecs.app_tg_arn
}

# Route53 module
module "route53" {
  source       = "./modules/route53"
  domain_name  = "sctp-sandbox.com"
  subdomain    = "ce-grp4"
  alb_dns      = module.ecs.alb_dns
  alb_zone_id  = module.ecs.alb_zone_id
  parent_zone_id = module.network.zone_id
}

 output "app_url" {
  description = "The HTTPS URL of the app"
  value       = "https://${module.route53.full_domain}"
}


resource "null_resource" "docker_build_and_push" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 255945442255.dkr.ecr.us-east-1.amazonaws.com
      docker build -t 255945442255.dkr.ecr.us-east-1.amazonaws.com/node-app:latest ./app
      docker push 255945442255.dkr.ecr.us-east-1.amazonaws.com/node-app:latest
    EOT
  }

  triggers = {
    hash = filesha256("${path.module}/app/Dockerfile")
  }

  depends_on = [module.ecr]
}
