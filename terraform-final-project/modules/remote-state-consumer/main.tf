variable "state_bucket" {
  description = "S3 bucket containing another Terraform state file."
  type        = string
}

variable "state_key" {
  description = "Object key for the remote state file."
  type        = string
}

variable "state_region" {
  description = "Region of the S3 state bucket."
  type        = string
}

data "terraform_remote_state" "shared_network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.state_key
    region = var.state_region
  }
}

output "remote_vpc_id" {
  description = "Example VPC ID consumed from another Terraform state."
  value       = try(data.terraform_remote_state.shared_network.outputs.vpc_id, null)
}
