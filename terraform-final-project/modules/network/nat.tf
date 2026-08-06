resource "aws_eip" "nat" {
  for_each = local.nat_gateway_keys

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-eip"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_keys

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.key == "nat-1" ? aws_subnet.public["public-1"].id : aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })

  depends_on = [aws_internet_gateway.main]
}
