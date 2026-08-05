output "zone_id" {
  description = "Route53 hosted zone ID."
  value       = local.zone_id
}

output "record_fqdn" {
  description = "Alias record FQDN."
  value       = try(aws_route53_record.alb[0].fqdn, null)
}
