# create log grp /ecs/myapp-app
locals {
  log_group_name = "/ecs/${var.name_prefix}-app"  # Single source of truth
}

# create log grp /ecs/myapp-app
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = local.log_group_name
}

resource "aws_ecs_task_definition" "nodejs_app_task" {
  family = "nodejs-app"
  depends_on = [ aws_cloudwatch_log_group.ecs_logs ]
  network_mode             = "awsvpc"       # Required for Fargate
  requires_compatibilities = ["FARGATE"]    # Explicitly declare Fargate
  cpu                      = 512            # Required for Fargate
  memory                   = 1024  

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      "name"              : "nodejs-app",
      "image"             :  "${aws_ecr_repository.app.repository_url}:latest" #"255945442255.dkr.ecr.us-east-1.amazonaws.com/rger-nodejs-xray:latest", // Your manually pushed image
      "memory"            : 128,
      "cpu"               : 256,
      "essential"         : true,
       logConfiguration = {  # Critical addition!
       logDriver = "awslogs",
       options   = {
                    "awslogs-group"         =  local.log_group_name # "/ecs/${local.prefix}-task",  # References the log group
                    "awslogs-region"        = "us-east-1",  # Change if your region differs
                    "awslogs-stream-prefix" = "ecs"         # Organizes log streams per task
                    }
        },
      "portMappings"      : [
        {
          "containerPort": 5000, # nodejs app port
          "hostPort"     : 5000, # Same for Fargate
          "protocol"     : "tcp"
        }
      ],
      "environment" : [
        {
          "name"  : "MONGODB_URI",
          "value" : "arn:aws:secretsmanager:us-east-1:255945442255:secret:prod/mongodb_uri" # Replace with your MongoDB URI
        }
      ],
      "secrets" : [
        {
          "name"      : "MONGO_URI", # Populates process.env.MONGO_URI
          "valueFrom" : "arn:aws:secretsmanager:us-east-1:255945442255:secret:prod/mongodb_uri-4rOgx9" # aws_secretsmanager_secret.mongo_uri.arn output
        }
      ]
    },
    {
      "name"              : "xray-sidecar",
      "image"             : "amazon/aws-xray-daemon",
      "memory"            : 128,
      "cpu"               : 256,
      "essential"         : false,
      "portMappings"      : [
        {
          "containerPort": 2000,
          "protocol"     : "udp"
        }
      ],
      "logConfiguration": {
        "logDriver" : "awslogs",
        "options"   : {
          "awslogs-group"         :  local.log_group_name,#"/ecs/nodejs-app-xray",
          "awslogs-region"        : "us-east-1",
          "awslogs-stream-prefix" : "xray-sidecar"
        }
      }
    }
  ])
}

# Link Task Definition to ECS Services  
resource "aws_ecs_service" "nodejs_app_service" {
  name            = "nodejs-app-xray-service"
  cluster         =  module.ecs.cluster_id    // Reference the cluster ID from the ECS module output
  task_definition = aws_ecs_task_definition.nodejs_app_task.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
 # Add this lifecycle block:
  lifecycle {
    ignore_changes = [ task_definition, desired_count ]
  }
  depends_on = [aws_ecs_task_definition.nodejs_app_task]
  
}

