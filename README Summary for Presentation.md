For ECS part here is the Group 4 project capstone summary:

Overview of Role-Based Access in AWS ECS
•	Tasks (Containers) assume Roles → Roles have attached Policies → Policies grant Permissions to AWS services.
Key Components
1. ECS Execution Role (aws_iam_role.ecs_execution_role)
•	This role is assumed by ECS tasks (sts:AssumeRole) to enable execution.
•	Service: "ecs-tasks.amazonaws.com"
•	Attached Policy: AmazonECSTaskExecutionRolePolicy (via aws_iam_role_policy_attachment.ecs_execution_role_policy)
•	Provides necessary permissions for pulling images, logging, and other execution-related tasks.
2. CloudWatch Logging Permissions (aws_iam_role_policy.ecs_logging)
•	Grants logging permissions to ECS execution role.
•	Actions:
o	"logs:CreateLogStream"
o	"logs:PutLogEvents"
•	Resources: CloudWatch log groups:
•	aws_cloudwatch_log_group.app
•	aws_cloudwatch_log_group.xray
3. X-Ray Tracing Role (aws_iam_role.ecs_xray_task_role)
•	Assumed by ECS tasks (sts:AssumeRole) for X-Ray tracing.
•	Service: "ecs-tasks.amazonaws.com"
•	Attached Policy: AWSXRayDaemonWriteAccess (via aws_iam_role_policy_attachment.xray_write_access)
•	Grants X-Ray daemon permission to write traces.
4. CloudWatch Log Groups
•	Application Logs: aws_cloudwatch_log_group.app ("/ecs/${var.name_prefix}-app")
•	X-Ray Logs: aws_cloudwatch_log_group.xray ("/ecs/${var.name_prefix}-xray-daemon")
Summary of Flow
•	ECS tasks assume ecs_execution_role, which enables execution.
•	CloudWatch Logs capture task activity using ecs_logging permissions.
•	X-Ray role (ecs_xray_task_role) enables distributed tracing.
•	Policies define what each role is allowed to do, ensuring security and controlled access.
This structure ensures that ECS tasks can run with the right permissions, log execution data, and perform distributed tracing using AWS X-Ray.

Overview of AWS Secrets Configuration in ECS
•	Tasks assume Roles, which have attached Policies that grant Permissions to access Secrets Manager.
Key Components
1. ECS Task Execution Role (aws_iam_role.ecs_task_execution_role)
•	Assumed by ECS tasks via sts:AssumeRole.
•	Service: "ecs-tasks.amazonaws.com"
•	Has two primary policies attached:
•	AmazonECSTaskExecutionRolePolicy → Standard execution permissions.
•	SecretsManagerReadWrite → Grants access to Secrets Manager.
2. Secrets Access Policy (aws_iam_role_policy.ecs_secrets_access)
•	Attached to ECS execution role (aws_iam_role.ecs_task_execution_role).
•	Permissions Granted:
o	"secretsmanager:GetSecretValue"
o	"secretsmanager:DescribeSecret"
•	Resources: Grants access to:
o	"arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:prod/mongodb_uri*".
•	Explicit Deny Rule: Prevents access to "ssm:*" to restrict unwanted secrets access.
3. X-Ray Role (aws_iam_role.ecs_xray_task_role)
•	Assumed by ECS tasks (sts:AssumeRole) for X-Ray tracing.
•	Attached Policies:
•	AWSXRayDaemonWriteAccess
•	SecretsManagerReadWrite (for selective secrets access).
4. CloudWatch Logging (aws_iam_role_policy.ecs_logging)
•	Grants permissions for logging task execution events.
•	Actions:
o	"logs:CreateLogStream"
o	"logs:PutLogEvents"
•	Resources: CloudWatch log groups:
•	aws_cloudwatch_log_group.ecs_logs
•	aws_cloudwatch_log_group.xray
5. ECS Task Definition (aws_ecs_task_definition.app)
•	Defines a secret to be injected into the container at runtime.
•	Secrets Block:
secrets = [{ name = "MONGODB_URI" valueFrom = aws_secretsmanager_secret.mongo_uri.arn }] 
•	Pulls MongoDB URI from Secrets Manager for secure usage.
Summary of Flow
•	ECS tasks assume ecs_task_execution_role, which provides execution capabilities and access to Secrets Manager.
•	Policies control access to secrets, ensuring only specific roles can retrieve sensitive data while enforcing security restrictions.
•	CloudWatch logs track execution, and X-Ray tracing monitors distributed traces.
•	Secrets are dynamically injected into task definitions, preventing hardcoded sensitive information.
This configuration ensures secure access to secrets for ECS tasks.

Summary of how AWS ECS and AWS Secrets Manager are configured together:
AWS ECS Setup
•	ECS Tasks assume IAM Roles to gain permissions for execution.
•	IAM Roles attach Policies that define what the task can access.
•	CloudWatch Logging is enabled for monitoring task execution.
•	X-Ray Tracing is integrated for distributed request tracking.
AWS Secrets Manager Integration
•	ECS Task Execution Role (ecs_task_execution_role) grants access to Secrets Manager.
•	Attached Policies:
o	AmazonECSTaskExecutionRolePolicy → Standard execution permissions.
o	SecretsManagerReadWrite → Allows the task to retrieve secrets securely.
•	Secrets are dynamically injected into ECS tasks using task definitions.
•	Task Definition Example:
secrets = [{ name = "MONGODB_URI" valueFrom = aws_secretsmanager_secret.mongo_uri.arn }] 
•	This ensures no hardcoded sensitive information in the task.
Summary of Flow
1.	ECS Tasks assume a Role to execute.
2.	Policies grant access to resources like logging and Secrets Manager.
3.	Secrets are injected dynamically into ECS tasks, preventing exposure.
4.	CloudWatch and X-Ray provide monitoring and debugging capabilities.
This setup ensures secure secret management, scalable execution, and efficient monitoring in AWS ECS.
