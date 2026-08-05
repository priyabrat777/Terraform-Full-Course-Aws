variable "name_prefix" {
  description = "Name prefix for storage resources."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for application storage."
  type        = string
}

variable "log_kms_key_arn" {
  description = "KMS key ARN for log storage."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EFS mount targets."
  type        = list(string)
}

variable "efs_security_group_id" {
  description = "Security group ID for EFS mount targets."
  type        = string
}

variable "enable_cloudfront" {
  description = "Create CloudFront distribution for the static site bucket."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to storage resources."
  type        = map(string)
  default     = {}
}
