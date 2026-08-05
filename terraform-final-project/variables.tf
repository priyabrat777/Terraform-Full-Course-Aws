variable "aws_region" {
  description = "Primary AWS region for the workload."
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region used by the provider alias and optional peered DR VPC."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Human-readable project name used for naming and tags."
  type        = string
  default     = "terraform-final-project"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9 -]{2,40}$", var.project_name))
    error_message = "project_name must start with a letter and contain 3-41 letters, numbers, spaces, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], lower(var.environment))
    error_message = "environment must be one of dev, test, staging, or prod."
  }
}

variable "owner" {
  description = "Team or person responsible for the infrastructure."
  type        = string
  default     = "platform-engineering"
}

variable "cost_center" {
  description = "Cost allocation code."
  type        = string
  default     = "training"
}

variable "application" {
  description = "Application or service name for tagging."
  type        = string
  default     = "capstone"
}

variable "additional_tags" {
  description = "Additional tags merged into every resource where tags are supported."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks. One subnet is created per item."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Provide at least two valid public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks. One subnet is created per item."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Provide at least two valid private subnet CIDR blocks."
  }
}

variable "availability_zones" {
  description = "Optional explicit AZ list. Leave empty to use the first available AZs in the selected region."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway resources for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for cost savings. Set false for one NAT gateway per public subnet."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Create gateway and interface VPC endpoints for private AWS service access."
  type        = bool
  default     = true
}

variable "enable_secondary_vpc" {
  description = "Create a small secondary-region VPC and cross-region VPC peering connection."
  type        = bool
  default     = false
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for the optional secondary-region VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to reach bastion/admin EC2 instances over SSH."
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type used by the launch template and optional admin instances."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must look like a valid EC2 instance type, for example t3.micro."
  }
}

variable "key_name" {
  description = "Optional EC2 key pair name. Null disables SSH key injection."
  type        = string
  default     = null
  nullable    = true
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the application Auto Scaling group."
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the application Auto Scaling group."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the application Auto Scaling group."
  type        = number
  default     = 4
}

variable "bastion_instance_count" {
  description = "Number of standalone admin EC2 instances to create. Demonstrates count and EBS blocks."
  type        = number
  default     = 0

  validation {
    condition     = var.bastion_instance_count >= 0 && var.bastion_instance_count <= 2
    error_message = "bastion_instance_count must be between 0 and 2."
  }
}

variable "db_name" {
  description = "Initial RDS database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "appadmin"
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "enable_rds_deletion_protection" {
  description = "Enable deletion protection on the RDS instance for production-like environments."
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Optional email address for SNS alert subscriptions."
  type        = string
  default     = ""

  validation {
    condition     = var.alert_email == "" || can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.alert_email))
    error_message = "alert_email must be empty or a valid email address."
  }
}

variable "enable_lambda" {
  description = "Create the event-driven Lambda processor and S3/SQS integrations."
  type        = bool
  default     = true
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "enable_cloudfront" {
  description = "Create CloudFront in front of the static site S3 bucket."
  type        = bool
  default     = true
}

variable "enable_ecs_service" {
  description = "Create an ECS Fargate service using the configured container image."
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image used by the ECS service."
  type        = string
  default     = "public.ecr.aws/nginx/nginx:stable"
}

variable "ecs_desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "enable_eks_cluster" {
  description = "Create an optional EKS cluster and managed node groups."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Optional DNS name. Required only when create_route53_zone or create_dns_record is true."
  type        = string
  default     = ""
}

variable "create_route53_zone" {
  description = "Create a Route53 public hosted zone for domain_name."
  type        = bool
  default     = false
}

variable "create_dns_record" {
  description = "Create an alias A record pointing domain_name to the ALB."
  type        = bool
  default     = false
}
