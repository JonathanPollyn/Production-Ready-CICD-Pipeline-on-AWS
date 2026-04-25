# -----------------------------------------------------------
# Terraform and provider version constraints
# Ensures consistent behavior across environments
# -----------------------------------------------------------

terraform {
  # Require a modern Terraform version
  required_version = ">= 1.6.0"

  # Define required providers and versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}