resource "aws_vpc_peering_connection" "secondary" {
  count = var.enable_secondary_vpc ? 1 : 0

  vpc_id      = aws_vpc.main.id
  peer_vpc_id = aws_vpc.secondary[0].id
  peer_region = data.aws_region.secondary.name
  auto_accept = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-primary-to-dr"
  })
}

resource "aws_vpc_peering_connection_accepter" "secondary" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.secondary[0].id
  auto_accept               = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dr-accepter"
  })
}

resource "aws_route" "primary_to_secondary" {
  for_each = var.enable_secondary_vpc ? merge(
    { public = aws_route_table.public.id },
    { for key, route_table in aws_route_table.private : key => route_table.id }
  ) : {}

  route_table_id            = each.value
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary[0].id

  depends_on = [aws_vpc_peering_connection_accepter.secondary]
}

resource "aws_route" "secondary_to_primary" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  route_table_id            = aws_route_table.secondary_public[0].id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary[0].id

  depends_on = [aws_vpc_peering_connection_accepter.secondary]
}
