resource "aws_route53_zone" "this" {
  count = var.create_zone && var.domain_name != "" ? 1 : 0

  name = var.domain_name
  tags = merge(var.tags, { Name = var.domain_name })
}

data "aws_route53_zone" "existing" {
  count = !var.create_zone && var.create_record && var.domain_name != "" ? 1 : 0

  name         = var.domain_name
  private_zone = false
}

locals {
  zone_id = var.create_zone && length(aws_route53_zone.this) > 0 ? aws_route53_zone.this[0].zone_id : (
    length(data.aws_route53_zone.existing) > 0 ? data.aws_route53_zone.existing[0].zone_id : null
  )
}

resource "aws_route53_record" "alb" {
  count = var.create_record && var.domain_name != "" ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
