# IAM role outputs
output "admin_role_arn" {
  description = "ARN of the admin role"
  value       = module.iam.admin_role_arn
}

output "terraform_role_arn" {
  description = "ARN of the terraform role"
  value       = module.iam.terraform_role_arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions role"
  value       = module.iam.github_actions_role_arn
}

output "backup_service_role_arn" {
  description = "ARN of the backup service role"
  value       = module.iam.backup_service_role_arn
}

# Networking outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.networking.database_subnet_ids
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.networking.web_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.networking.database_security_group_id
}

# ECR outputs
output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value       = module.ecr.ecr_repository_urls
}

output "ecr_registry_url" {
  description = "ECR registry URL for Docker commands"
  value       = module.ecr.ecr_registry_url
}

# DNS outputs
output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = module.dns.hosted_zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone (update these in Namecheap)"
  value       = module.dns.name_servers
}

output "domain_name" {
  description = "Domain name of the hosted zone"
  value       = module.dns.domain_name
}
