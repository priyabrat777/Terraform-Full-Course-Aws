resource "aws_db_subnet_group" "app" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "app" {
  identifier                 = "${var.name_prefix}-mysql"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_allocated_storage
  max_allocated_storage      = var.db_allocated_storage * 2
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.app.name
  vpc_security_group_ids     = [var.database_security_group_id]
  storage_encrypted          = true
  kms_key_id                 = var.kms_key_arn
  backup_retention_period    = 7
  backup_window              = "03:00-04:00"
  maintenance_window         = "sun:04:00-sun:05:00"
  multi_az                   = false
  publicly_accessible        = false
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = !var.deletion_protection
  final_snapshot_identifier  = var.deletion_protection ? "${var.name_prefix}-mysql-final" : null
  auto_minor_version_upgrade = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-mysql" })
}
