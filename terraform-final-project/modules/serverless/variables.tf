variable "name_prefix" {
  description = "Name prefix for serverless resources."
  type        = string
}

variable "enabled" {
  description = "Whether to create serverless resources."
  type        = bool
  default     = true
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda memory size."
  type        = number
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "source_bucket_id" {
  description = "S3 bucket that triggers Lambda."
  type        = string
}

variable "source_bucket_arn" {
  description = "Source S3 bucket ARN."
  type        = string
}

variable "destination_bucket_id" {
  description = "Destination S3 bucket for Lambda output."
  type        = string
}

variable "destination_bucket_arn" {
  description = "Destination S3 bucket ARN."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used by Lambda and SQS."
  type        = string
}

variable "tags" {
  description = "Tags applied to serverless resources."
  type        = map(string)
  default     = {}
}
