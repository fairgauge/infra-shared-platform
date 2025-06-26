variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

# Legacy variables (not used in this simplified version)
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (auto-calculated, this is legacy)"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (auto-calculated, this is legacy)"
  type        = list(string)
  default     = []
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets (auto-calculated, this is legacy)"
  type        = list(string)
  default     = []
}

variable "management_subnet_cidrs" {
  description = "CIDR blocks for management subnets (not implemented)"
  type        = list(string)
  default     = []
}

variable "enable_management_subnets" {
  description = "Enable management subnets (not implemented for cost savings)"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (cost optimization: use 1 for startup)"
  type        = number
  default     = 1
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints (disabled for cost savings)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs (disabled for cost savings)"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Flow log retention days (not used when flow logs disabled)"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}