variable "name_prefix" {
  description = "Name prefix for secrets."
  type        = string
}

variable "db_username" {
  description = "Database username stored with generated password."
  type        = string
  sensitive   = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for secret encryption."
  type        = string
}

variable "application_map" {
  description = "Non-secret application configuration stored as JSON."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to secrets."
  type        = map(string)
  default     = {}
}
