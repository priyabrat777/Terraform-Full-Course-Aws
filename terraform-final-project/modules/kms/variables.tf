variable "name_prefix" {
  description = "Name prefix for KMS aliases."
  type        = string
}

variable "tags" {
  description = "Tags applied to KMS resources."
  type        = map(string)
  default     = {}
}

variable "keys" {
  description = "KMS keys to create by purpose."
  type = map(object({
    description             = string
    deletion_window_in_days = number
    enable_key_rotation     = bool
  }))
  default = {
    app = {
      description             = "Application data encryption key"
      deletion_window_in_days = 10
      enable_key_rotation     = true
    }
    logs = {
      description             = "Logging and audit encryption key"
      deletion_window_in_days = 10
      enable_key_rotation     = true
    }
    secrets = {
      description             = "Secrets Manager and Parameter Store encryption key"
      deletion_window_in_days = 10
      enable_key_rotation     = true
    }
  }
}
