resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_internet_gateway" "secondary" {
  provider = aws.secondary
  count    = var.enable_secondary_vpc ? 1 : 0

  vpc_id = aws_vpc.secondary[0].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dr-igw"
  })
}
