
# --- ECR Repository ---
resource "aws_ecr_repository" "app" {
  name = "myapp-ecr"
image_tag_mutability = "MUTABLE" # Allows overwriting images
image_scanning_configuration {
    scan_on_push = true
  }
  lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
} 

