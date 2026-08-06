variable "name_prefix" {
  description = "Name prefix for load balancer resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs."
  type        = list(string)
}

variable "alb_security_group" {
  description = "ALB security group ID."
  type        = string
}

variable "tags" {
  description = "Tags applied to load balancer resources."
  type        = map(string)
  default     = {}
}
