provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "dr"
  region = var.secondary_region

  default_tags {
    tags = merge(local.common_tags, {
      RegionRole = "disaster-recovery"
    })
  }
}
