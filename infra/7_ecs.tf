# -----------------------------------------------------------
# ECS Cluster
# Logical group where ECS services and tasks run
# -----------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# -----------------------------------------------------------
# CloudWatch Log Group
# Stores application container logs from ECS
# -----------------------------------------------------------

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-${var.environment}-app"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}

# -----------------------------------------------------------
# ECS Task Definition
# Defines how the container should run in Fargate
# -----------------------------------------------------------

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # Smallest common Fargate size for demo/lab workloads
  cpu    = "256"
  memory = "512"

  # ECS uses execution role to pull image from ECR and write logs
  execution_role_arn = aws_iam_role.ecs_execution.arn

  # Application container uses task role for AWS permissions if needed later
  task_role_arn = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = tostring(var.app_port)
        },
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-task"
  }
}

# -----------------------------------------------------------
# ECS Service
# Keeps the application running on Fargate
# Connects ECS tasks to the ALB target group
# -----------------------------------------------------------

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # ECS tasks run in private subnets
  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  # Register ECS tasks with the ALB target group
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.app_port
  }

  # Wait for ALB listener before creating service
  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_execution_policy
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-service"
  }
}