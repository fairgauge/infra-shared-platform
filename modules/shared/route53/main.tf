resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, {
    Name        = "${var.project_name}-hosted-zone"
    Environment = var.environment
    Project     = var.project_name
  })
}

data "aws_route53_zone" "existing" {
  count = var.create_hosted_zone ? 0 : 1
  name  = var.domain_name
}

# Local values
locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# A record for main domain (if load balancer provided)
resource "aws_route53_record" "main" {
  count = var.load_balancer_dns_name != "" ? 1 : 0

  zone_id = local.zone_id
  name    = var.record_name != "" ? var.record_name : var.domain_name
  type    = "A"

  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "wildcard" {
  domain_name               = "*.${var.domain_name}"
  subject_alternative_names = [var.domain_name]  # Also covers root domain
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name = "${var.project_name}-wildcard-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation for the certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# MX records for email (optional)
resource "aws_route53_record" "mx" {
  count = var.create_mx_records ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = var.mx_ttl
  records = var.mx_records
}

# SPF record for email security
resource "aws_route53_record" "spf" {
  count = var.create_spf_record ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = var.txt_ttl
  records = [var.spf_record]
}

# DMARC record for email policy
resource "aws_route53_record" "dmarc" {
  count = var.create_dmarc_record ? 1 : 0

  zone_id = local.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = var.txt_ttl
  records = [var.dmarc_record]
}

# Custom TXT records
resource "aws_route53_record" "txt_records" {
  for_each = var.txt_records

  zone_id = local.zone_id
  name    = each.key
  type    = "TXT"
  ttl     = each.value.ttl
  records = each.value.records
}