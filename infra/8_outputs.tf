# -----------------------------------------------------------
# Useful Terraform Outputs
# These values help with testing and GitHub Actions setup
# -----------------------------------------------------------

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker image push"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "github_actions_role_arn" {
  description = "IAM role ARN used by GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}