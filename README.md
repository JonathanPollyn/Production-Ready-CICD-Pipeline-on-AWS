# Production-Ready-CICD-Pipeline-on-AWS
## Project Overview
This project outlines the deployment process for a containerized Node.js application on AWS, utilizing Terraform and GitHub Actions.

The application functions as a basic food menu service operating within a Docker container. Terraform is used to provision AWS infrastructure, while GitHub Actions automates  building the Docker image, uploading it to Amazon ECR, and deploying it to Amazon ECS Fargate.

## Architecture Summary

| Service | Purpose |
|--------|--------|
| Amazon VPC | Provides isolated networking environment |
| Public Subnets | Host the Application Load Balancer |
| Private Subnets | Host ECS Fargate tasks securely |
| Internet Gateway | Enables public internet access to ALB |
| NAT Gateway | Allows private ECS tasks to access the internet |
| Amazon ECR | Stores Docker container images |
| Amazon ECS Fargate | Runs the containerized application |
| Application Load Balancer | Routes incoming traffic to ECS |
| CloudWatch Logs | Stores application logs |
| IAM | Manages permissions and roles |
| GitHub Actions | Automates CI/CD pipeline |
| GitHub OIDC | Enables secure AWS authentication without keys |

## Folder Structure
```
Production-Ready-CICD-Pipeline-on-AWS/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── infra/
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── 1_vpc.tf
│   ├── 2_security_groups.tf
│   ├── 3_ecr.tf
│   ├── 4_iam_ecs.tf
│   ├── 5_iam_github_oidc.tf
│   ├── 6_alb.tf
│   ├── 7_ecs.tf
│   └── 8_outputs.tf
├── Dockerfile
├── package.json
├── package-lock.json
├── server.js
├── public/
│   └── index.html
└── .gitignore
```
## Application Flow
The application runs as a Node.js service inside a Docker container.
```
User Browser
   ↓
Application Load Balancer
   ↓
ECS Fargate Task
   ↓
Node.js Application
```
## CI/CD Flow

When code is pushed to the main branch:
```
GitHub Push
   ↓
GitHub Actions starts
   ↓
GitHub authenticates to AWS using OIDC
   ↓
Docker image is built
   ↓
Image is pushed to Amazon ECR
   ↓
ECS service is updated
   ↓
New container version goes live
```
## Prerequisites
Before using this project, install:
```
Terraform
AWS CLI
Git
Docker
Node.js
GitHub account
AWS account
```
## Terraform Deployment Steps

Go into the infrastructure folder:
```
cd infra
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```
## Important outputs:
```
application_url
ecr_repository_url
ecs_cluster_name
ecs_service_name
github_actions_role_arn
```
## GitHub Secret Setup
```
GitHub Repository → Settings → Secrets and variables → Actions → New repository secret
```
### Create this secret:
```
Name: AWS_ROLE_ARN
Value: arn:aws:iam::<account-id>:role/food-menu-cicd-dev-github-actions-role
```
## GitHub Actions Workflow
```
.github/workflows/deploy.yml
```
It performs these steps:

- Checks out the code
- Authenticates to AWS using OIDC
- Logs in to Amazon ECR
- Builds the Docker image
- Tags the Docker image
- Pushes the image to ECR
- Forces a new ECS deployment
## How to Deploy a New Version
Make a code change, then run:
```
git add .
git commit -m "Update application"
git push
```
GitHub Actions will automatically deploy the new version.

To manually trigger deployment without changing code:
```
git commit --allow-empty -m "Trigger deployment"
git push
```
## How to Access the Application
Use the Terraform output:
```
terraform output application_url
```
Example
```
http://food-menu-cicd-dev-alb-1964689178.us-east-1.elb.amazonaws.com
```
### How to Check Deployment Status
In GitHub

Go to:
```
GitHub Repository → Actions → Deploy to AWS ECS
```
Check whether the workflow succeeded or failed.

In AWS Console

Go to:
```
ECS → Clusters → food-menu-cicd-dev-cluster → Services
```
Check that the task is running.

Check ECS Logs

Go to:
```
CloudWatch → Log groups → /ecs/food-menu-cicd-dev-app
```
Use logs to troubleshoot application issues.

## Common Troubleshooting
Issue: GitHub Actions cannot assume role

Check:

- AWS_ROLE_ARN secret exists
- GitHub repo name matches Terraform variable
- branch is main
- OIDC role trust policy is correct
Issue: Docker build fails

Check:

- Dockerfile exists at project root
- package.json exists
- npm install or npm ci succeeds locally
Issue: ECS task keeps stopping

Check CloudWatch logs.

Common causes:

- App does not listen on port 3000
- App does not bind to 0.0.0.0
- Missing dependency
- Wrong start command

Recommended server binding:
```
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Food Menu Service running on port ${PORT}`);
});
```
Issue: ALB shows unhealthy target

Check:

- Health check path is /health
- App has /health route
- Security group allows ALB to ECS on port 3000
- ECS task is running
Security Design
- ECS tasks run in private subnets
- ALB is the only public entry point
- ECS security group only allows traffic from ALB
- GitHub Actions uses OIDC instead of AWS access keys
- IAM roles follow least privilege principles
- Docker images are scanned in ECR
- Terraform state files are ignored in Git
## Cost Management

This project creates billable resources.
```
NAT Gateway
Application Load Balancer
ECS Fargate
ECR storage
CloudWatch logs
```
## User Guide
- Clone the repo
- Configure AWS CLI
- Update terraform.tfvars
- Run Terraform apply
- Add AWS_ROLE_ARN to GitHub secrets
- Push code to main
- Watch GitHub Actions deploy
- Open the ALB URL
- Destroy infrastructure when finished
## Author

**Jonathan Pollyn**  
Senior Data Analyst | Data Engineer | Cloud & DevOps Enthusiast  

- LinkedIn: https://www.linkedin.com/in/jonathan-ibifubara-pollyn-ms-ds-8482a1110/ 
- GitHub: https://github.com/JonathanPollyn  
- Portfolio: https://pollynzconsults.ai
- Email: jpollyn@pollynzconsults.ai