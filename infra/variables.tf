# -----------------------------------------------------------
# Input variables for reusable and configurable infrastructure
# -----------------------------------------------------------

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "project_name" {
  description = "This is the project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB lives here)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (ECS tasks live here)"
  type        = list(string)
}

variable "app_port" {
  description = "Port the application listens on inside the container"
  type        = number
  default     = 3000
}

# -----------------------------------------------------------
# GitHub configuration (used for OIDC CI/CD integration)
# -----------------------------------------------------------

variable "github_org" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to deploy"
  type        = string
  default     = "main"
}