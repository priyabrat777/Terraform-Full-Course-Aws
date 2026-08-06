variable "name_prefix" {
  description = "Name prefix for network resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "availability_zones" {
  description = "Optional AZ list."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to create only one NAT gateway."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Whether to create VPC endpoints."
  type        = bool
  default     = true
}

variable "enable_secondary_vpc" {
  description = "Whether to create a secondary-region VPC and VPC peering."
  type        = bool
  default     = false
}

variable "secondary_vpc_cidr" {
  description = "Secondary VPC CIDR."
  type        = string
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach ALB."
  type        = list(string)
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to reach admin instances over SSH."
  type        = list(string)
}

variable "interface_endpoint_services" {
  description = "Interface endpoint short service names."
  type        = set(string)
  default     = ["ecr.api", "ecr.dkr", "logs", "secretsmanager", "ssm", "ssmmessages", "ec2messages"]
}
