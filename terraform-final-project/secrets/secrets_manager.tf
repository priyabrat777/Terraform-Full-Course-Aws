resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.name_prefix}/database/credentials"
  description             = "Database credentials for ${var.name_prefix}."
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-credentials" })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
  })
}

resource "aws_secretsmanager_secret" "app_config" {
  name                    = "${var.name_prefix}/application/config"
  description             = "Application configuration for ${var.name_prefix}."
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7

  tags = merge(var.tags, { Name = "${var.name_prefix}-app-config" })
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id     = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode(var.application_map)
}
