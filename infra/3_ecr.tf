# -----------------------------------------------------------
# Amazon ECR Repository
# Stores the Docker image built from the application code
# GitHub Actions will push images here
# ECS Fargate will pull images from here
# -----------------------------------------------------------

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "MUTABLE"

  # Scan container images for known vulnerabilities on push
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-ecr"
  }
}

# -----------------------------------------------------------
# ECR Lifecycle Policy
# Keeps only the most recent images to reduce storage cost
# -----------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}