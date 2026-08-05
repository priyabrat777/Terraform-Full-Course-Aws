output "db_password" {
  description = "Generated database password."
  value       = random_password.db.result
  sensitive   = true
}

output "secret_arns" {
  description = "Secrets Manager ARNs."
  value = {
    db_credentials = aws_secretsmanager_secret.db_credentials.arn
    app_config     = aws_secretsmanager_secret.app_config.arn
  }
}

output "ssm_parameter_names" {
  description = "SSM parameter names."
  value = {
    environment = aws_ssm_parameter.environment.name
    db_password = aws_ssm_parameter.db_password.name
  }
}
