# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition
}

# 1. Admin Role - Cross-account admin access
resource "aws_iam_role" "admin" {
  name = "${var.project_name}-shared-admin-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.admin_user_arns
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
  
  tags = var.tags
}

# Attach PowerUserAccess policy to admin role
resource "aws_iam_role_policy_attachment" "admin_power_user" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/PowerUserAccess"
}

# Attach IAM read access to admin role
resource "aws_iam_role_policy_attachment" "admin_iam_read" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/IAMReadOnlyAccess"
}

# 2. Terraform Role - Infrastructure management
resource "aws_iam_role" "terraform" {
  name = "${var.project_name}-shared-terraform-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = concat(
            var.terraform_user_arns,
            [aws_iam_role.github_actions.arn]  # Allow GitHub Actions to assume this role
          )
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
  
  tags = var.tags
}

# Attach PowerUserAccess to terraform role
resource "aws_iam_role_policy_attachment" "terraform_power_user" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/PowerUserAccess"
}

# Custom policy for Terraform IAM permissions
resource "aws_iam_policy" "terraform_iam" {
  name = "${var.project_name}-shared-terraform-iam-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = var.tags
}

# Attach custom IAM policy to terraform role
resource "aws_iam_role_policy_attachment" "terraform_iam" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_iam.arn
}

# 3. GitHub OIDC Provider (conditional)
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0
  
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = [
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"  # GitHub's current thumbprint
  ]
  
  tags = var.tags
}

# 4. GitHub Actions Role
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-shared-github-actions-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.github_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_repository_refs
          }
        }
      }
    ]
  })
  
  tags = var.tags
}

# GitHub Actions role gets permission to assume terraform role
resource "aws_iam_role_policy" "github_actions_assume_terraform" {
  name = "${var.project_name}-shared-github-actions-assume-terraform"
  role = aws_iam_role.github_actions.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = aws_iam_role.terraform.arn
      }
    ]
  })
}

# ECR policy for GitHub Actions role
resource "aws_iam_policy" "github_actions_ecr" {
  name = "${var.project_name}-shared-github-actions-ecr-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          "arn:${local.partition}:ecr:${local.region}:${local.account_id}:repository/fairgauge-*"
        ]
      }
    ]
  })
  
  tags = var.tags
}

# Attach ECR policy to GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

# 5. AWS Backup Service Role (conditional)
resource "aws_iam_role" "backup_service" {
  count = var.enable_backup_service_role ? 1 : 0
  name  = "${var.project_name}-shared-backup-service-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# Attach AWS Backup service policy
resource "aws_iam_role_policy_attachment" "backup_service" {
  count      = var.enable_backup_service_role ? 1 : 0
  role       = aws_iam_role.backup_service[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}