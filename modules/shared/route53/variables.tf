variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

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

# Load balancer configuration
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

# Email configuration
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

variable "mx_ttl" {
  description = "TTL for MX records"
  type        = number
  default     = 3600
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

variable "txt_ttl" {
  description = "TTL for TXT records"
  type        = number
  default     = 3600
}

variable "txt_records" {
  description = "Map of custom TXT records"
  type = map(object({
    ttl     = number
    records = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}