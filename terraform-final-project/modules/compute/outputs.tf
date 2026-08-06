output "launch_template_id" {
  description = "Launch template ID."
  value       = aws_launch_template.app.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling group name."
  value       = aws_autoscaling_group.app.name
}

output "admin_instance_ids" {
  description = "Optional admin instance IDs."
  value       = aws_instance.admin[*].id
}
