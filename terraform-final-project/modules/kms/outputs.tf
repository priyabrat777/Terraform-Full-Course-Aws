output "key_ids" {
  description = "KMS key IDs by purpose."
  value       = { for key, value in aws_kms_key.this : key => value.key_id }
}

output "key_arns" {
  description = "KMS key ARNs by purpose."
  value       = { for key, value in aws_kms_key.this : key => value.arn }
}

output "alias_names" {
  description = "KMS alias names by purpose."
  value       = { for key, value in aws_kms_alias.this : key => value.name }
}
