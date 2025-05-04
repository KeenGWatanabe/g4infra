
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
          "arn:aws:secretsmanager:us-east-1:255945442255:secret:${local.prefix}/db_pass*",
          # Add other secret ARNs if needed
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_s3_access" {
  name_prefix = "${local.prefix}-s3-access"
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
          "arn:aws:s3:::rgers3.tfstate-backend.com",
          "arn:aws:s3:::rgers3.tfstate-backend.com/*",
          "arn:aws:dynamodb:us-east-1:255945442255:table/terraform-state-locks"
        ]
      }
    ]
  })
  lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
}




