ECSpart2/
├── infra/
│   ├── main.tf                  # Root module
│   ├── variables.tf             # Central variables
│   ├── terraform.tfvars         # Variable values
│   ├── outputs.tf               # Output values
│   ├── provider.tf              # AWS provider config
│   ├── ecr.tf                   # ECR repository
│   ├── iam.tf                   # IAM roles
│   ├── data.tf                  # Data sources
│   └── modules/
│       ├── vpc/
│       │   ├── main.tf          # VPC resources
│       │   ├── alb.tf           # ALB resources
│       │   ├── endpoints.tf     # VPC endpoints
│       │   ├── subnets.tf       # Subnet config
│       │   └── variables.tf     # VPC module variables
│       └── ecs/
│           ├── main.tf          # ECS service
│           ├── task-definition.tf # Task definition
│           ├── security.tf      # Security groups
│           └── variables.tf     # ECS module variables
|___ app /
     ├── app.py
     ├── Dockerfile
     └── requirements.txt