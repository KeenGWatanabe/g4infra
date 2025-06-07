resource "aws_ecr_repository" "node_app" {
  name = "node-app"
}

resource "null_resource" "docker_build_and_push" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.node_app.repository_url}
      docker build -t ${aws_ecr_repository.node_app.repository_url}:latest ../app
      docker push ${aws_ecr_repository.node_app.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.node_app]
}

variable "aws_region" {
  type = string
}

output "image_url" {
  value = aws_ecr_repository.node_app.repository_url
}
