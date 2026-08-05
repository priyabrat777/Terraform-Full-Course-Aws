output "bucket_names" {
  description = "S3 bucket names by purpose."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.id }
}

output "bucket_arns" {
  description = "S3 bucket ARNs by purpose."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.arn }
}

output "efs_file_system_id" {
  description = "EFS file system ID."
  value       = aws_efs_file_system.app.id
}

output "efs_mount_target_ids" {
  description = "EFS mount target IDs."
  value       = [for target in aws_efs_mount_target.app : target.id]
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name when enabled."
  value       = try(aws_cloudfront_distribution.app[0].domain_name, null)
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID when enabled."
  value       = try(aws_cloudfront_distribution.app[0].hosted_zone_id, null)
}
