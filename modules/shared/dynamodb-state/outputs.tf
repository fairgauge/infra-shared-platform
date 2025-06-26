output "terraform_lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.arn
}

output "app_state_table_name" {
  description = "Name of the application state table"
  value       = var.create_app_state_table ? aws_dynamodb_table.app_state[0].name : null
}

output "app_state_table_arn" {
  description = "ARN of the application state table"
  value       = var.create_app_state_table ? aws_dynamodb_table.app_state[0].arn : null
}