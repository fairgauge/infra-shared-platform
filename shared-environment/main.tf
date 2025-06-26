terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "s3" {
    # Backend configuration will be provided via backend.tfvars
    # Uses bootstrap resources:
    # - S3 bucket: fairgauge-shared-terraform-state-970547365042
    # - DynamoDB table: fairgauge-shared-terraform-state-lock
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  environment = "shared"
  
  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  # Network configuration
  availability_zones = slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))
}

# Phase 3: IAM infrastructure for shared environment
module "iam" {
  source = "../modules/shared/iam"

  project_name = var.project_name
  external_id  = var.external_id

  admin_user_arns     = var.admin_user_arns
  terraform_user_arns = var.terraform_user_arns
  local_user_arns     = var.local_user_arns

  create_github_oidc_provider = var.create_github_oidc_provider
  github_oidc_provider_arn   = var.github_oidc_provider_arn
  github_repository_refs     = var.github_repository_refs

  enable_backup_service_role = var.enable_backup_service_role
  enable_rds_monitoring_role = var.enable_rds_monitoring_role

  tags = local.common_tags
}

# Phase 4: Shared networking infrastructure
module "networking" {
  source = "../modules/shared/networking"

  project_name       = var.project_name
  vpc_cidr          = var.vpc_cidr
  availability_zones = local.availability_zones
  
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs
  management_subnet_cidrs = var.management_subnet_cidrs
  
  enable_management_subnets = var.enable_management_subnets
  nat_gateway_count        = var.nat_gateway_count
  enable_vpc_endpoints     = var.enable_vpc_endpoints
  enable_flow_logs         = var.enable_flow_logs
  flow_log_retention_days  = var.flow_log_retention_days

  tags = local.common_tags
}

# Phase 5: ECR (Container Registry)
module "ecr" {
  source = "../modules/shared/ecr"

  project_name = var.project_name
  
  # ECR repositories to create
  ecr_repositories = var.ecr_repositories
  
  # Lifecycle policies
  enable_lifecycle_policy = var.enable_ecr_lifecycle_policy
  max_image_count        = var.ecr_max_image_count
  
  # Cross-account access
  allow_cross_account_pull = var.allow_cross_account_pull
  trusted_account_ids     = var.trusted_account_ids

  tags = local.common_tags
}

# Phase 6: DNS management (hosted zone creation)
module "dns" {
  source = "../modules/shared/route53"

  project_name = var.project_name
  environment  = local.environment
  domain_name  = var.domain_name

  create_hosted_zone = var.create_hosted_zone
  record_name       = var.record_name
  
  # No load balancer yet for shared env
  load_balancer_dns_name = var.load_balancer_dns_name
  load_balancer_zone_id  = var.load_balancer_zone_id

  # Email and DNS records
  create_mx_records   = var.create_mx_records
  mx_records         = var.mx_records
  create_spf_record  = var.create_spf_record
  spf_record         = var.spf_record
  create_dmarc_record = var.create_dmarc_record
  dmarc_record       = var.dmarc_record
  txt_records        = var.txt_records

  tags = local.common_tags
}