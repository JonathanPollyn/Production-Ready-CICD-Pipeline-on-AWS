# -----------------------------------------------------------
# Environment-specific values (acts like config)
# -----------------------------------------------------------

aws_region   = "us-east-1"
project_name = "food-menu-cicd"
environment  = "dev"

# VPC network range
vpc_cidr = "10.0.0.0/16"

# Public subnets (internet-facing resources like ALB)
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

# Private subnets (secure backend resources like ECS)
private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# Application port (matches Node app)
app_port = 3000

github_org    = "JonathanPollyn"
github_repo   = "Production-Ready-CICD-Pipeline-on-AWS"
github_branch = "main"