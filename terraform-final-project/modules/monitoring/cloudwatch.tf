resource "aws_cloudwatch_log_group" "application" {
  name              = "/application/${var.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_arn
  tags              = merge(var.tags, { Name = "${var.name_prefix}-application-logs" })
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ALB Request Count"
          region  = var.aws_region
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]]
          stat    = "Sum"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ASG and RDS CPU"
          region = var.aws_region
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 6
        width  = 24
        height = 3
        properties = {
          markdown = "### ${var.name_prefix}\nApplication bucket: `${var.app_bucket_name}`\nManaged by Terraform."
        }
      }
    ]
  })
}
