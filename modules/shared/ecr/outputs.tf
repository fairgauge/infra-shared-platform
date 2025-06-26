output "ecr_repository_urls" {
  description = "Map of repository names to URLs"
  value       = local.repository_urls
}

output "ecr_repository_arns" {
  description = "Map of repository names to ARNs"
  value = {
    for repo_name, repo in aws_ecr_repository.repositories :
    repo_name => repo.arn
  }
}

output "ecr_repository_names" {
  description = "List of ECR repository names"
  value       = [for repo in aws_ecr_repository.repositories : repo.name]
}

output "ecr_registry_url" {
  description = "ECR registry URL"
  value       = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}