variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ecr_repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["api", "frontend", "worker"]
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy to manage image retention"
  type        = bool
  default     = true
}

variable "max_image_count" {
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}