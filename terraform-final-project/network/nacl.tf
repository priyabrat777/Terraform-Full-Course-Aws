resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.public : subnet.id]

  dynamic "ingress" {
    for_each = local.nacl_ingress_rules
    content {
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      protocol   = ingress.value.protocol
      cidr_block = ingress.value.cidr_block
    }
  }

  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-nacl"
  })
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.vpc_cidr
  }

  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-nacl"
  })
}
