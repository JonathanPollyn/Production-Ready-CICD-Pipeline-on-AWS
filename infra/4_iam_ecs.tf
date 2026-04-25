# -----------------------------------------------------------
# ECS Task Execution Role
# This role is used by ECS itself to:
# - Pull images from ECR
# - Send logs to CloudWatch
# - Read secrets if needed later
# -----------------------------------------------------------

resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-execution-role"
  }
}

# -----------------------------------------------------------
# Attach AWS-managed ECS execution policy
# Provides permissions for ECR pull and CloudWatch logs
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------------
# ECS Task Role
# This role is used by the application container itself.
# For now it has no extra permissions.
# Later, you can add permissions for S3, DynamoDB, Secrets Manager, etc.
# -----------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-task-role"
  }
}