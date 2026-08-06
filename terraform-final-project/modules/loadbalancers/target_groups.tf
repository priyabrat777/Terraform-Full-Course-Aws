resource "aws_lb_target_group" "app" {
  name     = substr("${var.name_prefix}-app-tg", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-app-tg" })
}

resource "aws_lb_target_group" "tcp" {
  name        = substr("${var.name_prefix}-tcp-tg", 0, 32)
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-tcp-tg" })
}
