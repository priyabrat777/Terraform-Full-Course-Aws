resource "aws_lb" "app" {
  name               = substr("${var.name_prefix}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb" })
}

resource "aws_lb" "network" {
  name               = substr("${var.name_prefix}-nlb", 0, 32)
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-nlb" })
}
