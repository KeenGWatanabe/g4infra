resource "aws_iam_role_policy" "ecr_pull" {
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      Effect   = "Allow",
      Resource = "arn:aws:ecr:us-east-1:255945442255:repository/myapp-ecr"
    }]
  })
}
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "ecs-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:255945442255:secret:${var.name_prefix}/db_pass*",
          # Add other secret ARNs if needed
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_s3_access" {
  name_prefix = "${var.name_prefix}-s3-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::ce994.tfstate-backend.com",
          "arn:aws:s3:::ce994.tfstate-backend.com/*",
          "arn:aws:dynamodb:us-east-1:255945442255:table/terraform-state-locks"
        ]
      }
    ]
  })
  lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
}





# Task Execution Role - for ECS agent
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-taskexecutionrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
    lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
}

# Attach managed policies
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# under-review "which secrets manager"
resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"  # Broad permissions for testing
}

# Task Role - for application
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-xray-taskrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach Secrets Manager read permissions to the ECS task role
resource "aws_iam_role_policy" "secrets_access" {
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = "arn:aws:secretsmanager:us-east-1:255945442255:secret:prod/mongodb_uri-GqnR0f" # [aws_secretsmanager_secret.mongo_uri.arn]
    }]
  })
}

# Reference the secret ARN from the Secrets Repo
data "aws_secretsmanager_secret" "mongo_uri" {
  name = aws_secretsmanager_secret.dbpass.name
}


resource "aws_iam_role_policy_attachment" "xray_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy" "ecs_logging" {
  name = "${var.name_prefix}-ecs-logging"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource = [
          "arn:aws:logs:us-east-1:255945442255:log-group:/ecs/${var.name_prefix}-*",
          "arn:aws:logs:us-east-1:255945442255:log-group:/ecs/${var.name_prefix}-*:*"
        ]
      }
    ]
  })
}