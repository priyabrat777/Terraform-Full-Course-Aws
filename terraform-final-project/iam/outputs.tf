output "ec2_instance_profile_name" {
  description = "EC2 instance profile name."
  value       = aws_iam_instance_profile.ec2.name
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN."
  value       = aws_iam_role.ecs_task.arn
}

output "role_arns" {
  description = "IAM role ARNs."
  value = {
    ec2                = aws_iam_role.ec2.arn
    ecs_task_execution = aws_iam_role.ecs_task_execution.arn
    ecs_task           = aws_iam_role.ecs_task.arn
  }
}

output "user_names" {
  description = "Optional IAM user names."
  value       = [for user in aws_iam_user.this : user.name]
}
