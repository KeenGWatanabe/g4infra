<H1>For ECS part here is the Group 4 project capstone summary:</H1>

<h2>Overview of Role-Based Access in AWS ECS</h2>
•	Tasks (Containers) assume Roles → Roles have attached Policies → Policies grant Permissions to AWS services. <BR>
<br>

<b>Key Components</b>
1. ECS Execution Role (aws_iam_role.ecs_execution_role) <BR>
•	This role is assumed by ECS tasks (sts:AssumeRole) to enable execution. <BR>
•	Service: "ecs-tasks.amazonaws.com" <BR>
•	Attached Policy: AmazonECSTaskExecutionRolePolicy (via aws_iam_role_policy_attachment.ecs_execution_role_policy) <BR>
•	Provides necessary permissions for pulling images, logging, and other execution-related tasks. <BR>

2. CloudWatch Logging Permissions (aws_iam_role_policy.ecs_logging)
•	Grants logging permissions to ECS execution role. <BR>
•	Actions: <BR>
o	"logs:CreateLogStream" <BR>
o	"logs:PutLogEvents" <BR>
•	Resources: CloudWatch log groups: <BR>
•	aws_cloudwatch_log_group.app <BR>
•	aws_cloudwatch_log_group.xray <BR>

3. X-Ray Tracing Role (aws_iam_role.ecs_xray_task_role)
•	Assumed by ECS tasks (sts:AssumeRole) for X-Ray tracing. <BR>
•	Service: "ecs-tasks.amazonaws.com" <BR>
•	Attached Policy: AWSXRayDaemonWriteAccess (via aws_iam_role_policy_attachment.xray_write_access) <BR>
•	Grants X-Ray daemon permission to write traces. <BR>

4. CloudWatch Log Groups
•	Application Logs: aws_cloudwatch_log_group.app ("/ecs/${var.name_prefix}-app") <BR>
•	X-Ray Logs: aws_cloudwatch_log_group.xray ("/ecs/${var.name_prefix}-xray-daemon") <BR>

<b>Summary of Flow</b> <BR>
•	ECS tasks assume ecs_execution_role, which enables execution. <BR>
•	CloudWatch Logs capture task activity using ecs_logging permissions. <BR>
•	X-Ray role (ecs_xray_task_role) enables distributed tracing. <BR>
•	Policies define what each role is allowed to do, ensuring security and controlled access. <BR>
This structure ensures that ECS tasks can run with the right permissions, log execution data, and perform distributed tracing using AWS X-Ray. <BR><BR>

<b>Overview of AWS Secrets Configuration in ECS</b>
•	Tasks assume Roles, which have attached Policies that grant Permissions to access Secrets Manager. <BR>

<b>Key Components</b> <BR>
1. ECS Task Execution Role (aws_iam_role.ecs_task_execution_role) <BR>
•	Assumed by ECS tasks via sts:AssumeRole. <BR>
•	Service: "ecs-tasks.amazonaws.com" <BR>
•	Has two primary policies attached: <BR>
•	AmazonECSTaskExecutionRolePolicy → Standard execution permissions.<BR>
•	SecretsManagerReadWrite → Grants access to Secrets Manager. <BR>

2. Secrets Access Policy (aws_iam_role_policy.ecs_secrets_access) <BR>
•	Attached to ECS execution role (aws_iam_role.ecs_task_execution_role). <BR>
•	Permissions Granted: <BR>
o	"secretsmanager:GetSecretValue" <BR>
o	"secretsmanager:DescribeSecret" <BR>
•	Resources: Grants access to: <BR>
o	"arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:prod/mongodb_uri*". <BR>
•	Explicit Deny Rule: Prevents access to "ssm:*" to restrict unwanted secrets access. <BR>

3. X-Ray Role (aws_iam_role.ecs_xray_task_role) <BR>
•	Assumed by ECS tasks (sts:AssumeRole) for X-Ray tracing. <BR>
•	Attached Policies: <BR>
•	AWSXRayDaemonWriteAccess <BR>
•	SecretsManagerReadWrite (for selective secrets access). <BR>

4. CloudWatch Logging (aws_iam_role_policy.ecs_logging) <BR>
•	Grants permissions for logging task execution events. <BR>
•	Actions: <BR>
o	"logs:CreateLogStream" <BR>
o	"logs:PutLogEvents" <BR>
•	Resources: CloudWatch log groups: <BR>
•	aws_cloudwatch_log_group.ecs_logs <BR>
•	aws_cloudwatch_log_group.xray <BR>

5. ECS Task Definition (aws_ecs_task_definition.app) <BR>
•	Defines a secret to be injected into the container at runtime. <BR>
•	Secrets Block: <BR>
secrets = [{ name = "MONGODB_URI" valueFrom = aws_secretsmanager_secret.mongo_uri.arn }]  <BR>
•	Pulls MongoDB URI from Secrets Manager for secure usage. <BR>

<b>Summary of Flow</b> <BR>
•	ECS tasks assume ecs_task_execution_role, which provides execution capabilities and access to Secrets Manager. <BR>
•	Policies control access to secrets, ensuring only specific roles can retrieve sensitive data while enforcing security restrictions. <BR>
•	CloudWatch logs track execution, and X-Ray tracing monitors distributed traces. <BR>
•	Secrets are dynamically injected into task definitions, preventing hardcoded sensitive information. <BR>
This configuration ensures secure access to secrets for ECS tasks. <BR>

<b>Summary of how AWS ECS and AWS Secrets Manager are configured together:</b> <BR>

AWS ECS Setup <BR>
•	ECS Tasks assume IAM Roles to gain permissions for execution. <BR>
•	IAM Roles attach Policies that define what the task can access. <BR>
•	CloudWatch Logging is enabled for monitoring task execution. <BR>
•	X-Ray Tracing is integrated for distributed request tracking. <BR>

AWS Secrets Manager Integration <BR>
•	ECS Task Execution Role (ecs_task_execution_role) grants access to Secrets Manager. <BR>
•	Attached Policies: <BR>
o	AmazonECSTaskExecutionRolePolicy → Standard execution permissions. <BR>
o	SecretsManagerReadWrite → Allows the task to retrieve secrets securely. <BR>
•	Secrets are dynamically injected into ECS tasks using task definitions. <BR>
•	Task Definition Example: <BR>
secrets = [{ name = "MONGODB_URI" valueFrom = aws_secretsmanager_secret.mongo_uri.arn }]  <BR>
•	This ensures no hardcoded sensitive information in the task. <BR>

<h2>Summary of Flow</h2> <BR>
1.	ECS Tasks assume a Role to execute. <BR>
2.	Policies grant access to resources like logging and Secrets Manager. <BR>
3.	Secrets are injected dynamically into ECS tasks, preventing exposure. <BR>
4.	CloudWatch and X-Ray provide monitoring and debugging capabilities. <BR>
This setup ensures secure secret management, scalable execution, and efficient monitoring in AWS ECS. <BR>
