variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for DynamoDB tables"
  type        = bool
  default     = false
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

variable "enable_point_in_time_recovery" {
  description = "Enable point in time recovery for DynamoDB"
  type        = bool
  default     = false
}

variable "create_app_state_table" {
  description = "Create application state table"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}