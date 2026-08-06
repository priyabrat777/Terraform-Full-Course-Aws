output "rds_endpoint" {
  description = "RDS instance endpoint."
  value       = aws_db_instance.app.endpoint
  sensitive   = true
}

output "rds_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.app.id
}

output "rds_subnet_group_name" {
  description = "RDS subnet group name."
  value       = aws_db_subnet_group.app.name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = aws_dynamodb_table.app.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN."
  value       = aws_dynamodb_table.app.arn
}
