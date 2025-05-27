resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Permissions for CloudWatch
resource "aws_iam_role_policy" "ecs_logging" {
  name = "ecs-execution-logs"
  role = aws_iam_role.ecs_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
          ],
        Resource = [
          "${aws_cloudwatch_log_group.app.arn}:*",
          "${aws_cloudwatch_log_group.xray.arn}:*"
        ] #"arn:aws:logs:us-east-1:255945442255:log-group:/ecs/${var.name_prefix}-app:*"
      }
    ]
  })
}

# Create ECS Task Role (for X-Ray write access)
resource "aws_iam_role" "ecs_xray_task_role" {
  name = "${var.name_prefix}-ecs-xray-taskrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
          }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role       = aws_iam_role.ecs_xray_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}