variable "name_prefix" {
  description = "Name prefix for database resources."
  type        = string
}

variable "db_name" {
  description = "Initial RDS database name."
  type        = string
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS DB instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
}

variable "deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = false
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS."
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Security group ID for RDS."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for database encryption."
  type        = string
}

variable "tags" {
  description = "Tags applied to database resources."
  type        = map(string)
  default     = {}
}
