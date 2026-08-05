variable "name_prefix" {
  description = "Name prefix for container resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS task security group ID."
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN."
  type        = string
}

variable "container_image" {
  description = "Container image for ECS."
  type        = string
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
}

variable "enable_ecs_service" {
  description = "Create ECS service."
  type        = bool
  default     = true
}

variable "enable_eks_cluster" {
  description = "Create optional EKS cluster."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN."
  type        = string
}

variable "tags" {
  description = "Tags applied to container resources."
  type        = map(string)
  default     = {}
}
