variable "name_prefix" {
  description = "Name prefix for IAM resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}

variable "iam_users" {
  description = "Optional IAM users to create for training group membership examples."
  type = map(object({
    path       = optional(string, "/")
    department = optional(string, "platform")
  }))
  default = {}
}
