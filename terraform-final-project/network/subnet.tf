resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
    Tier = "private"
  })
}

resource "aws_subnet" "secondary_public" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  vpc_id                  = aws_vpc.secondary[0].id
  cidr_block              = cidrsubnet(var.secondary_vpc_cidr, 8, 1)
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dr-public-1"
    Tier = "public"
  })
}
