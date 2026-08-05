resource "aws_efs_file_system" "app" {
  encrypted        = true
  kms_key_id       = var.kms_key_arn
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-efs" })
}

resource "aws_efs_backup_policy" "app" {
  file_system_id = aws_efs_file_system.app.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "app" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.app.id
  subnet_id        = each.value
  security_groups  = [var.efs_security_group_id]
}
