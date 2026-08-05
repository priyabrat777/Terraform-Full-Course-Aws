variable "domain_name" {
  description = "Domain name for Route53."
  type        = string
}

variable "create_zone" {
  description = "Create a public hosted zone."
  type        = bool
  default     = false
}

variable "create_record" {
  description = "Create an alias record."
  type        = bool
  default     = false
}

variable "alb_dns_name" {
  description = "ALB DNS name."
  type        = string
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID."
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront domain name."
  type        = string
  default     = ""
}

variable "cloudfront_zone_id" {
  description = "CloudFront hosted zone ID."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to DNS resources."
  type        = map(string)
  default     = {}
}
