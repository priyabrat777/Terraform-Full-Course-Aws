output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.app.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics."
  value       = aws_lb.app.arn_suffix
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "ALB Route53 zone ID."
  value       = aws_lb.app.zone_id
}

output "app_target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.app.arn
}

output "app_target_group_arn_suffix" {
  description = "Application target group ARN suffix."
  value       = aws_lb_target_group.app.arn_suffix
}

output "nlb_dns_name" {
  description = "NLB DNS name."
  value       = aws_lb.network.dns_name
}
