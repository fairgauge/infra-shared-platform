# Project configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = ""
}

# IAM configuration
variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
}

variable "admin_user_arns" {
  description = "List of user ARNs that can assume admin role"
  type        = list(string)
  default     = []
}

variable "terraform_user_arns" {
  description = "List of user ARNs that can assume terraform role"
  type        = list(string)
  default     = []
}

variable "local_user_arns" {
  description = "List of user ARNs for local development"
  type        = list(string)
  default     = []
}

variable "create_github_oidc_provider" {
  description = "Create GitHub OIDC provider"
  type        = bool
  default     = true
}

variable "github_oidc_provider_arn" {
  description = "ARN of existing GitHub OIDC provider"
  type        = string
  default     = ""
}

variable "github_repository_refs" {
  description = "List of GitHub repository refs that can assume the GitHub Actions role"
  type        = list(string)
  default     = []
}

variable "enable_backup_service_role" {
  description = "Create AWS Backup service role"
  type        = bool
  default     = false
}

variable "enable_rds_monitoring_role" {
  description = "Create RDS monitoring role"
  type        = bool
  default     = false
}

# Networking configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (legacy - auto-calculated)"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (legacy - auto-calculated)"
  type        = list(string)
  default     = []
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets (legacy - auto-calculated)"
  type        = list(string)
  default     = []
}

variable "management_subnet_cidrs" {
  description = "CIDR blocks for management subnets"
  type        = list(string)
  default     = []
}

variable "enable_management_subnets" {
  description = "Enable management subnets"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (1 for cost optimization)"
  type        = number
  default     = 0
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Flow log retention days"
  type        = number
  default     = 7
}

# ECR configuration
variable "ecr_repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = []
}

variable "enable_ecr_lifecycle_policy" {
  description = "Enable lifecycle policy to manage image retention"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of tagged images to keep"
  type        = number
  default     = 10
}

variable "allow_cross_account_pull" {
  description = "Allow cross-account access to pull images"
  type        = bool
  default     = false
}

variable "trusted_account_ids" {
  description = "List of AWS account IDs that can pull images"
  type        = list(string)
  default     = []
}

# DNS configuration
variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "create_hosted_zone" {
  description = "Create a new hosted zone"
  type        = bool
  default     = true
}

variable "record_name" {
  description = "Record name for A record (leave empty for root domain)"
  type        = string
  default     = ""
}

variable "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
  default     = ""
}

variable "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
  default     = ""
}

variable "create_mx_records" {
  description = "Create MX records for email"
  type        = bool
  default     = false
}

variable "mx_records" {
  description = "List of MX records"
  type        = list(string)
  default     = []
}

variable "create_spf_record" {
  description = "Create SPF record"
  type        = bool
  default     = false
}

variable "spf_record" {
  description = "SPF record value"
  type        = string
  default     = "v=spf1 -all"
}

variable "create_dmarc_record" {
  description = "Create DMARC record"
  type        = bool
  default     = false
}

variable "dmarc_record" {
  description = "DMARC record value"
  type        = string
  default     = "v=DMARC1; p=none;"
}

variable "txt_records" {
  description = "Map of custom TXT records"
  type = map(object({
    ttl     = number
    records = list(string)
  }))
  default = {}
}