variable "name_prefix" {
  description = "Name prefix for monitoring resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region for dashboard links and metric dimensions."
  type        = string
}

variable "alert_email" {
  description = "Optional alert email."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix."
  type        = string
}

variable "alb_target_group_arn_suffix" {
  description = "ALB target group ARN suffix."
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling group name."
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance identifier."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name."
  type        = string
  default     = null
  nullable    = true
}

variable "app_bucket_name" {
  description = "Application bucket name for dashboard context."
  type        = string
}

variable "log_kms_key_arn" {
  description = "KMS key ARN for monitoring logs."
  type        = string
}

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
