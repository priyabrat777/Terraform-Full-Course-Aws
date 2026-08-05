output "sns_topic_arn" {
  description = "SNS alerts topic ARN."
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "audit_bucket_name" {
  description = "Audit S3 bucket name."
  value       = aws_s3_bucket.audit.id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN."
  value       = aws_cloudtrail.main.arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name."
  value       = aws_config_configuration_recorder.main.name
}

output "alarm_names" {
  description = "CloudWatch alarm names."
  value = concat(
    [
      aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
      aws_cloudwatch_metric_alarm.target_unhealthy.alarm_name,
      aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
      aws_cloudwatch_metric_alarm.application_errors.alarm_name
    ],
    [for alarm in aws_cloudwatch_metric_alarm.lambda_errors : alarm.alarm_name]
  )
}
