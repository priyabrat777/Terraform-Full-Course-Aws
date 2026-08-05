locals {
  normalized_project     = lower(replace(var.project_name, " ", "-"))
  normalized_environment = lower(var.environment)
  name_prefix            = "${local.normalized_project}-${local.normalized_environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      Terraform   = "true"
      ManagedBy   = "terraform"
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.additional_tags
  )
}
