resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Tier = "public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.private_route_table_keys

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-rt"
    Tier = "private"
  })
}

resource "aws_route" "private_nat" {
  for_each = var.enable_nat_gateway ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? "nat-1" : local.private_nat_gateway_for_route_table[each.key]].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[local.private_route_table_for_subnet[each.key]].id
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  vpc_id = aws_vpc.secondary[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dr-public-rt"
  })
}

resource "aws_route_table_association" "secondary_public" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  subnet_id      = aws_subnet.secondary_public[0].id
  route_table_id = aws_route_table.secondary_public[0].id
}
