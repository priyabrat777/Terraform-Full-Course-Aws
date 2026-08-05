resource "aws_ssm_parameter" "environment" {
  name        = "/${var.name_prefix}/environment"
  description = "Application environment."
  type        = "String"
  value       = lookup(var.application_map, "environment", "dev")
  tags        = merge(var.tags, { Name = "${var.name_prefix}-environment" })
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.name_prefix}/database/password"
  description = "Database password copy for services that use Parameter Store."
  type        = "SecureString"
  value       = random_password.db.result
  key_id      = var.kms_key_arn
  tags        = merge(var.tags, { Name = "${var.name_prefix}-db-password" })
}
