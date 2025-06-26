Website presentation
https://keengwatanabe.github.io/g4infra

# 1. Application Load Balancer (ALB) Configuration (alb.tf)

[!Resources_alb](/images/RESOURCES_ALB.png)

ALB Resource (aws_lb.app): Creates an internet-facing Application Load Balancer to distribute incoming traffic across ECS tasks.

Target Group (aws_lb_target_group.app): Defines a group of targets (ECS tasks) that the ALB routes requests to. It listens on port 5000 and performs health checks on the /health endpoint to ensure targets are healthy.

SSL Certificate (aws_acm_certificate.app): Requests an SSL/TLS certificate for the domain ce-grp-4.sctp-sandbox.com using DNS validation. This certificate enables HTTPS traffic to the ALB.stackoverflow.com+11registry.terraform.io+11registry.terraform.io+11

HTTPS Listener (aws_lb_listener.https): Configures the ALB to listen on port 443 (HTTPS) and forward traffic to the target group using the SSL certificate.stackoverflow.com

HTTP Listener (aws_lb_listener.app): Sets up the ALB to listen on port 80 (HTTP) and redirect all HTTP requests to HTTPS, ensuring secure communication.


Security Group for ALB (aws_security_group.alb): Allows inbound HTTP (port 80) and HTTPS (port 443) traffic from any source and permits all outbound traffic.

![RESOURCES_listeners](/images/RESOURCES_listenrers.png)

# 2 Data Sources (data.tf)
![RESOURCES_data1](/images/RESOURCES_data1.png)

![RESOURCES_data2](/images/RESOURCES_data2.png)

Subnets (aws_subnets.private & aws_subnets.public): Fetches information about private and public subnets within the specified VPC. These are used to place the ALB and ECS tasks appropriately.

VPC (aws_vpc.selected): Retrieves details about the VPC where resources are deployed.

# 3 IAM roles and policies (iam.tf)

![RESOURCES_IAM](/images/resources_iam.png)

ECS Execution Role (aws_iam_role.ecs_execution_role): Grants ECS tasks permissions to pull container images and publish logs to CloudWatch.

Policy Attachment (aws_iam_role_policy_attachment.ecs_execution_role_policy): Attaches the AWS-managed policy AmazonECSTaskExecutionRolePolicy to the execution role, providing necessary permissions for ECS tasks.

Logging Policy (aws_iam_role_policy.ecs_logging): Defines an inline policy allowing ECS tasks to create log streams and put log events in CloudWatch for both application and X-Ray logs.

X-Ray Task Role (aws_iam_role.ecs_xray_task_role): Provides ECS tasks with permissions to send trace data to AWS X-Ray for distributed tracing.

X-Ray Policy Attachment (aws_iam_role_policy_attachment.xray_write_access): Attaches the AWS-managed policy AWSXRayDaemonWriteAccess to the X-Ray task role.spacelift.io+1geeksforgeeks.org+1

# Main configuration (main.tf)
![Resources_main1](/images/resources_main1.png)

![Resources_main2](/images/resources_main2.png)

![Resources_main3](/images/resources_main3.png)

![Resources_main4](/images/resources_main4.png)

Terraform Backend: Stores Terraform state in an S3 bucket with state locking managed by DynamoDB to prevent concurrent modifications.

AWS Provider: Specifies the AWS region (us-east-1) for resource deployment.

Random ID (random_id.suffix): Generates a unique identifier to append to resource names, ensuring uniqueness.

ECS Cluster Module (module.ecs): Deploys an ECS cluster using the terraform-aws-modules/ecs/aws module, configured with Fargate and Fargate Spot capacity providers.

CloudWatch Log Groups (aws_cloudwatch_log_group.app & aws_cloudwatch_log_group.xray): Creates log groups for application and X-Ray logs with a retention period of 30 days.

ECS Task Definition (aws_ecs_task_definition.app): Defines the ECS task with two containers:

Application Container: Runs the main application, listens on port 5000, and logs to CloudWatch.

X-Ray Daemon: Runs the X-Ray daemon for tracing, listens on UDP port 2000, and logs to CloudWatch.

ECS Service (aws_ecs_service.app): Deploys the ECS service using the task definition, assigns it to the ALB target group, and places tasks in private subnets with public IPs assigned.

ECR Repository (aws_ecr_repository.app): Creates an Elastic Container Registry to store Docker images for the application.

# 6 Variables and Environment Configurations
Variables (variables.tf & variable.tf): Defines input variables such as MONGO_URI, vpc_id, name_prefix, alb_subnet_ids, and private_subnet_ids to parameterize the Terraform configuration.

Environment-Specific Variables (terraform.tfvars, dev.tfvars, prod.tfvars, rger.tfvars): Provides values for the defined variables tailored to different environments (development, production, etc.).
![resources_var](/images/resources_var.png)
# 7 Outputs (outputs.tf)
ECS Cluster Name: Outputs the name of the ECS cluster for reference.

Service URL: Outputs the DNS name of the ALB, which serves as the entry point to the application.

This Terraform configuration sets up a scalable, secure, and observable infrastructure for deploying containerized applications on AWS. If you need further assistance or have specific questions about any part of this setup, feel free to ask!
Sources

# Cloudwatch
![CloudWatch1](/images/CloudWatch1.png)

![CloudWatch2](/images/Cloudwatch2.png)

![Cloudwatch3](/images/Cloudwatch3.png)

![Cloudwatch4](/images/Cloudwatch4.png)

![Cloudwatch5](/images/Cloudwatch5.png)

![Cloudwatch6](/images/Cloudwatch6.png)

![Cloudwatch7](/images/Cloudwatch7.png)

# Dashboard

![Dashboard1](/images/Dashboard1.png)

![Dashboard2](/images/Dashboard2.png)
