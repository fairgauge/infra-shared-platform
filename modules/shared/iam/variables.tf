variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
}

# User ARNs for role assumption
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
  description = "List of user ARNs for local development (not used in this module)"
  type        = list(string)
  default     = []
}

# GitHub OIDC configuration
variable "create_github_oidc_provider" {
  description = "Create GitHub OIDC provider"
  type        = bool
  default     = true
}

variable "github_oidc_provider_arn" {
  description = "ARN of existing GitHub OIDC provider (if not creating new one)"
  type        = string
  default     = ""
}

variable "github_repository_refs" {
  description = "List of GitHub repository refs that can assume the GitHub Actions role"
  type        = list(string)
  default     = []
}

# Service roles
variable "enable_backup_service_role" {
  description = "Create AWS Backup service role"
  type        = bool
  default     = false
}

variable "enable_rds_monitoring_role" {
  description = "Create RDS monitoring role (not implemented in this version)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}