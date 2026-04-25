# -----------------------------------------------------------
# AWS Provider Configuration
# Defines region and default tags applied to all resources
# -----------------------------------------------------------

provider "aws" {
  # AWS region (from variables)
  region = var.aws_region

  # Apply consistent tagging to all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}