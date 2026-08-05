output "vpc_id" {
  description = "Primary VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs by purpose."
  value       = module.network.security_group_ids
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = module.loadbalancers.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Application Auto Scaling group name."
  value       = module.compute.autoscaling_group_name
}

output "s3_bucket_names" {
  description = "S3 bucket names by purpose."
  value       = module.storage.bucket_names
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name when enabled."
  value       = module.storage.cloudfront_domain_name
}

output "rds_endpoint" {
  description = "RDS endpoint."
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = module.database.dynamodb_table_name
}

output "iam_role_arns" {
  description = "IAM role ARNs."
  value       = module.iam.role_arns
}

output "kms_key_arns" {
  description = "KMS key ARNs by purpose."
  value       = module.kms.key_arns
}

output "secret_arns" {
  description = "Secrets Manager secret ARNs."
  value       = module.secrets.secret_arns
}

output "ssm_parameter_names" {
  description = "SSM Parameter Store names."
  value       = module.secrets.ssm_parameter_names
}

output "lambda_function_name" {
  description = "Lambda function name when enabled."
  value       = module.serverless.lambda_function_name
}

output "sqs_queue_url" {
  description = "SQS queue URL when serverless is enabled."
  value       = module.serverless.queue_url
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.containers.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.containers.ecs_cluster_name
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID when created."
  value       = module.dns.zone_id
}

output "sns_topic_arn" {
  description = "SNS topic ARN for infrastructure alerts."
  value       = module.monitoring.sns_topic_arn
}

output "resource_group_arn" {
  description = "AWS Resource Group ARN for project-tagged resources."
  value       = aws_resourcegroups_group.project.arn
}
