# Project configuration
project_name = "fairgauge"
owner        = "fairgauge-team"
cost_center  = "engineering"

# IAM configuration
external_id = "fairgauge-external-id-2025"  # Use a secure random string

# User ARNs
admin_user_arns = [
  "arn:aws:iam::970547365042:user/siddhant"
]

terraform_user_arns = []  # Empty - only GitHub Actions will assume terraform role

# GitHub configuration
create_github_oidc_provider = true
github_repository_refs = [
  "repo:fairgauge/*:*"  # All fairgauge repos
]

# Service roles
enable_backup_service_role = true   # Enable backup service role
enable_rds_monitoring_role = false  # Skip for now

# Networking configuration (cost-optimized for startup)
vpc_cidr = "10.0.0.0/16"

# Cost optimizations
nat_gateway_count     = 1     # Single NAT Gateway (~$45/month vs $135 for 3)
enable_vpc_endpoints  = false # Skip VPC endpoints (~$7/month each)
enable_flow_logs      = false # Skip flow logs (CloudWatch costs)
enable_management_subnets = false # Skip management subnets

# ECR configuration
ecr_repositories = [
  "frontend-service",
  "rest-api-gateway", 
  "websocket-gateway",
  "user-service",
  "analytics-service", 
  "market-data-websocket"
]
enable_ecr_lifecycle_policy = true   # Keep costs low by cleaning old images
ecr_max_image_count        = 20      # Keep last 10 tagged images
allow_cross_account_pull   = true   # Enable later when you have prod account
trusted_account_ids        = ["970547365042"]      # Add prod account ID later

# DNS configuration
domain_name = "fairgauge.com"

# Hosted zone management
create_hosted_zone = true  # Create new hosted zone in this account
record_name       = ""     # Empty for root domain

# Load balancer (not used yet)
load_balancer_dns_name = ""
load_balancer_zone_id  = ""

# Google Workspace email configuration
create_mx_records   = true
mx_records         = ["1 smtp.google.com"]
create_spf_record  = true
spf_record         = "v=spf1 include:_spf.google.com ~all"
create_dmarc_record = false  
dmarc_record       = "v=DMARC1; p=none;"
txt_records        = {}     # Empty for now, can add custom TXT records later