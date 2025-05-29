terraform {
  backend "s3" {
    bucket         = "ce994.tfstate-backend.com"  # Must match the bucket name above
    key            = "infra/terraform.tfstate"        # State file path
    region         = "us-east-1"                # Same as provider
    dynamodb_table = "terraform-state-locks"    # If using DynamoDB
    # use_lockfile   = true                       # replaces dynamodb_table                
    encrypt        = true                       # Use encryption
  }
}
provider "aws" {
  region = "us-east-1" # Change if needed
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {  # <-- This was missing
  state = "available"
}



# --- ECS Cluster & Service ---
module "ecs" {
  depends_on = [ aws_ecr_repository.app ]
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.name_prefix}-ecs"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    myapp-service = {
      # Use a static map structure for container_definitions
      container_definitions = {
        (var.container_name) = { #dynamic key fr var.tf
          name      = var.container_name #reused here
          essential = true
          image     = "${aws_ecr_repository.app.repository_url}:latest"
          cpu       = 512
          memory    = 1024 # Important: Add these dummy entries to prevent unknown values
          port_mappings = [
            {
              containerPort = 8080
              hostPort      = 8080
              protocol     = "tcp"
            }
          ]
          
          # Add required fields
          environment = [] 
          # secrets     = []
          mount_points = []
          volumes_from = []
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = aws_subnet.public[*].id
      security_group_ids                 = [aws_security_group.ecs.id]
      # Add these required fields
      enable_execute_command = true
      task_exec_iam_role_arn = aws_iam_role.ecs_task_execution_role.arn
    }
  }
}

