output "hosted_zone_id" {
  description = "ID of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

output "hosted_zone_arn" {
  description = "ARN of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].arn : data.aws_route53_zone.existing[0].arn
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

output "domain_name" {
  description = "Domain name of the hosted zone"
  value       = var.domain_name
}