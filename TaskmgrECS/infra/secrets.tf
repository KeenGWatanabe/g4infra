
resource "aws_secretsmanager_secret" "dbpass" {
  name = "/${var.name_prefix}/dbpass"
}

resource "aws_secretsmanager_secret_version" "dbpass_version" {
  secret_id     = aws_secretsmanager_secret.dbpass.id
  secret_string = jsonencode({
    password = "P@ssw0rd"
  })
}