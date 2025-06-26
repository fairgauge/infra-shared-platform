# Admin role outputs
output "admin_role_arn" {
  description = "ARN of the admin role"
  value       = aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "Name of the admin role"
  value       = aws_iam_role.admin.name
}

# Terraform role outputs
output "terraform_role_arn" {
  description = "ARN of the terraform role"
  value       = aws_iam_role.terraform.arn
}

output "terraform_role_name" {
  description = "Name of the terraform role"
  value       = aws_iam_role.terraform.name
}

# GitHub Actions role outputs
output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions role"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions role"
  value       = aws_iam_role.github_actions.name
}

# GitHub OIDC provider outputs
output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.github_oidc_provider_arn
}

# Backup service role outputs
output "backup_service_role_arn" {
  description = "ARN of the backup service role"
  value       = var.enable_backup_service_role ? aws_iam_role.backup_service[0].arn : null
}

output "backup_service_role_name" {
  description = "Name of the backup service role"
  value       = var.enable_backup_service_role ? aws_iam_role.backup_service[0].name : null
}