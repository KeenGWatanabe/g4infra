# this terraforms one Container for app, IGW (pub subnets) NAT (pte subnets) 
modules/ecs/
├── main.tf [ecs, alb, iam, security] # Primary ECS resources
├── variables.tf     # Input variables
├── data.tf
├── terraform.tfvars # Outputs from vpc, mongo_uri
├── outputs.tf       # Output values
└── README.md        # Documentation

# for production will spin up backen S3

# in case module "ecs" cloudwatch error
terraform import module.ecs.module.cluster.aws_cloudwatch_log_group.this[0] "/aws/ecs/nodejs-app-cluster"

# create if cloutdwatch error via cli
aws logs create-log-group --log-group-name /ecs/nodejs-app


# build and push a new Docker image
docker build -t your-app-name .
docker tag your-app-name:latest your-account-id.dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest
docker push your-account-id.dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest

# new deployment in ECS
once successful tasks and services, go to website
ECS > Clusters > `cluster-name` > Services > `service-name` > Configuration > DNS names 

# recreate cluster via cli
aws ecs create-service \
    --cluster nodejs-app-cluster \
    --service-name nodejs-app-service \
    --task-definition arn:aws:ecs:us-east-1:255945442255:task-definition/nodejs-app-task:5 \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-0c0137fdc2b0f229c,subnet-0cd0906f4e874731e],securityGroups=[sg-0721f22958cfab32b],assignPublicIp=\"ENABLED\"}"

# Manual cleanup sequence:
terraform destroy

# aws console cleanup:  
# ANOTHER TF WITH SEPARATE VPC AND ECS WOULD NOT NEED TO DO BELOW
Delete load balancers
Delete Load Balancing-Target groups

Delete NAT gateways

Release Elastic IPs

Delete subnets / associated network

Delete route tables

Delete internet gateways

Finally delete VPC

ending
