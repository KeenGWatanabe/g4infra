# create log grp /ecs/myapp-app
locals {
  log_group_name = "/ecs/${local.prefix}-app"  # Single source of truth
}

# create log grp /ecs/myapp-app
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = local.log_group_name
}

resource "aws_ecs_task_definition" "flask_app_task" {
  family = "flask-app-xray-family"
  depends_on = [ aws_cloudwatch_log_group.ecs_logs ]
  network_mode             = "awsvpc"       # Required for Fargate
  requires_compatibilities = ["FARGATE"]    # Explicitly declare Fargate
  cpu                      = 512            # Required for Fargate
  memory                   = 1024  

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      "name"              : "flask-app",
      "image"             :  "${aws_ecr_repository.app.repository_url}:latest" #"255945442255.dkr.ecr.us-east-1.amazonaws.com/rger-flask-xray:latest", // Your manually pushed image
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
          "containerPort": 8080,
          "protocol"     : "tcp"
        }
      ],
      "environment" : [
        {
          "name"  : "SERVICE_NAME",
          "value" : "rger-flask-xray-service"
        }
      ],
      "secrets" : [
        {
          "name"      : "MY_APP_CONFIG",
          "valueFrom" : aws_ssm_parameter.app_config.arn
        },
        {
          "name"      : "MY_DB_PASS",
          "valueFrom" : aws_secretsmanager_secret.db_pass.arn
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
          "awslogs-group"         :  local.log_group_name,#"/ecs/flask-app-xray",
          "awslogs-region"        : "us-east-1",
          "awslogs-stream-prefix" : "xray-sidecar"
        }
      }
    }
  ])
}

# Link Task Definition to ECS Services  
resource "aws_ecs_service" "flask_app_service" {
  name            = "flask-app-xray-service"
  cluster         =  module.ecs.cluster_id    // Reference the cluster ID from the ECS module output
  task_definition = aws_ecs_task_definition.flask_app_task.arn
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
  depends_on = [aws_ecs_task_definition.flask_app_task]
  
}

