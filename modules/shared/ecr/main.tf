# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# ECR Repositories
resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.ecr_repositories)
  
  name                 = "${var.project_name}-${each.value}"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  tags = merge(var.tags, {
    Name        = "${var.project_name}-${each.value}"
    Repository  = each.value
  })
}

# Lifecycle policies to manage image retention and costs
resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = var.enable_lifecycle_policy ? aws_ecr_repository.repositories : {}
  
  repository = each.value.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release", "prod"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Cross-account access policy (for prod environment to pull images)
data "aws_iam_policy_document" "ecr_cross_account" {
  count = var.allow_cross_account_pull ? 1 : 0
  
  statement {
    sid    = "CrossAccountPull"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [
        for account_id in var.trusted_account_ids :
        "arn:aws:iam::${account_id}:root"
      ]
    }
    
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
  
  statement {
    sid    = "LambdaECRImageCrossAccount"
    effect = "Allow"
    
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }
}

# Apply cross-account policy to repositories
resource "aws_ecr_repository_policy" "cross_account" {
  for_each = var.allow_cross_account_pull ? aws_ecr_repository.repositories : {}
  
  repository = each.value.name
  policy     = data.aws_iam_policy_document.ecr_cross_account[0].json
}

# ECR Repository URLs output for easy reference
locals {
  repository_urls = {
    for repo_name, repo in aws_ecr_repository.repositories :
    repo_name => repo.repository_url
  }
}