terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.66.1"
    }
  }

  # backend "s3" {
  #   # bucket         = "ce-grp-4-tfstate-backend-dev"
  #   # key            = "g4infra/dev/terraform.tfstate"
  #   # region         = "us-east-1"
  #   # dynamodb_table = "ce-grp-4-terraform-state-locks-dev"
  # }
}