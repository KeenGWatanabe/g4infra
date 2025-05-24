terraform {
  backend "s3" {
    bucket         = "ce-grp-4.tfstate-backend.com"
    key            = "g4infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks" # Critical for locking
  }
}


provider "aws" {
  region = "us-east-1"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "nodejs-app-cluster"
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }
  # Capacity provider - Fargate
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = {
    Environment = "production"
    Application = "nodejs-app"
  }
}
# Create CLoudWatch Log Group for taskDef reference
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/nodejs-app"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "app" {
  family                   = "nodejs-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512  #1024 
  memory                   = 1024 #2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "nodejs-app"
    image     = "${aws_ecr_repository.app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
    environment = [
      {
        name  = "MONGODB_ATLAS_URI"
        value = var.MONGO_URI
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/nodejs-app"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    },
    {
      "name" : "xray-daemon",
      "image" : "amazon/aws-xray-daemon:latest",
      "essential" : false,
      "portMappings" : [
        {
          "containerPort" : 2000,
          "protocol" : "udp"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/your-log-group",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "xray"
        }
      }
  }])
}

# unique ID for certain resources
resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_ecs_service" "app" {
  name            = "nodejs-app-service-${random_id.suffix.hex}"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids # aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "nodejs-app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.app]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "nodejs-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
