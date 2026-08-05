data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}

data "aws_region" "secondary" {
  provider = aws.secondary
}

locals {
  selected_azs = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  public_subnets = {
    for index, cidr in var.public_subnet_cidrs : "public-${index + 1}" => {
      cidr = cidr
      az   = local.selected_azs[index % length(local.selected_azs)]
      index = index
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs : "private-${index + 1}" => {
      cidr = cidr
      az   = local.selected_azs[index % length(local.selected_azs)]
      index = index
    }
  }

  nat_gateway_keys = var.enable_nat_gateway ? (
    var.single_nat_gateway ? toset(["nat-1"]) : toset(keys(local.public_subnets))
  ) : toset([])

  private_route_table_keys = var.single_nat_gateway ? toset(["private-shared"]) : toset(keys(local.private_subnets))

  private_route_table_for_subnet = {
    for key, subnet in local.private_subnets : key => (
      var.single_nat_gateway ? "private-shared" : key
    )
  }

  private_nat_gateway_for_route_table = {
    for key, subnet in local.private_subnets : key => (
      var.single_nat_gateway ? "nat-1" : "public-${(subnet.index % length(var.public_subnet_cidrs)) + 1}"
    )
  }

  nacl_ingress_rules = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 110
      action     = "allow"
      from_port  = 443
      to_port    = 443
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 120
      action     = "allow"
      from_port  = 1024
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    }
  ]
}
