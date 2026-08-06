data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "admin" {
  count = var.bastion_instance_count

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.admin_security_group_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume.size
    volume_type           = var.root_volume.type
    encrypted             = true
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      encrypted             = true
      delete_on_termination = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-admin-${count.index + 1}"
    Role = "admin"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}
