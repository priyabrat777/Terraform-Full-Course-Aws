output "lambda_function_name" {
  description = "Lambda function name."
  value       = try(aws_lambda_function.processor[0].function_name, null)
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = try(aws_lambda_function.processor[0].arn, null)
}

output "queue_url" {
  description = "SQS queue URL."
  value       = try(aws_sqs_queue.events[0].url, null)
}

output "queue_arn" {
  description = "SQS queue ARN."
  value       = try(aws_sqs_queue.events[0].arn, null)
}
