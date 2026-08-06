resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile("${path.root}/scripts/user_data.sh", {
    app_name    = var.name_prefix
    environment = lookup(var.tags, "Environment", "unknown")
    bucket_name = var.app_bucket_name
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume.size
      volume_type           = var.root_volume.type
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-app"
      Role = "application"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-app-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
