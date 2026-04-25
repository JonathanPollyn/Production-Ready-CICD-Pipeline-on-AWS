# -----------------------------------------------------------
# GitHub OIDC Provider
# Allows GitHub Actions to authenticate to AWS without
# storing long-term AWS access keys in GitHub secrets
# -----------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub Actions OIDC thumbprint
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-github-oidc"
  }
}

# -----------------------------------------------------------
# Trust policy for GitHub Actions
# Restricts AWS role access to only my GitHub repo and branch
# -----------------------------------------------------------

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    # GitHub token audience must be AWS STS
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only allow my specific repo and branch to assume this role
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

# -----------------------------------------------------------
# IAM Role assumed by GitHub Actions
# GitHub Actions uses this role to push images to ECR
# and update ECS services
# -----------------------------------------------------------

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-github-actions-role"
  }
}

# -----------------------------------------------------------
# GitHub Actions Deployment Policy
# Allows GitHub Actions to:
# - Push Docker images to ECR
# - Register ECS task definitions
# - Update ECS services
# - Pass ECS roles to ECS task definitions
# -----------------------------------------------------------

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${var.project_name}-${var.environment}-github-actions-policy"
  description = "Permissions for GitHub Actions to deploy application to ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR authorization token is required before Docker can push to ECR
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },

      # Permissions to push Docker image layers to the specific ECR repository
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages"
        ]
        Resource = aws_ecr_repository.app.arn
      },

      # Permissions to describe and update ECS resources
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },

      # Required so GitHub Actions can register a task definition
      # using the ECS execution role and task role
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution.arn,
          aws_iam_role.ecs_task.arn
        ]
      }
    ]
  })
}

# -----------------------------------------------------------
# Attach deployment policy to GitHub Actions role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}