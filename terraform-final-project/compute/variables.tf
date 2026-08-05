variable "name_prefix" {
  description = "Name prefix for compute resources."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
  nullable    = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ASG."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for optional admin instances."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application security group ID."
  type        = string
}

variable "admin_security_group_id" {
  description = "Admin security group ID."
  type        = string
}

variable "instance_profile_name" {
  description = "EC2 instance profile name."
  type        = string
}

variable "target_group_arns" {
  description = "Target group ARNs attached to the ASG."
  type        = list(string)
}

variable "asg_min_size" {
  description = "ASG minimum size."
  type        = number
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity."
  type        = number
}

variable "asg_max_size" {
  description = "ASG maximum size."
  type        = number
}

variable "bastion_instance_count" {
  description = "Optional standalone admin EC2 count."
  type        = number
  default     = 0
}

variable "app_bucket_name" {
  description = "Application S3 bucket name exposed to user data."
  type        = string
}

variable "tags" {
  description = "Tags applied to compute resources."
  type        = map(string)
  default     = {}
}

variable "root_volume" {
  description = "Root volume configuration for EC2 instances."
  type = object({
    size = number
    type = string
  })
  default = {
    size = 20
    type = "gp3"
  }
}

variable "additional_ebs_volumes" {
  description = "Additional EBS block devices for the optional admin EC2 instances."
  type = list(object({
    device_name = string
    size        = number
    type        = string
  }))
  default = []
}
