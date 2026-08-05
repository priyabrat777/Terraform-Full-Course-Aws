resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name_prefix}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "ALB is returning elevated 5xx responses."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb-5xx" })
}

resource "aws_cloudwatch_metric_alarm" "target_unhealthy" {
  alarm_name          = "${var.name_prefix}-target-unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "One or more ALB targets are unhealthy."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.alb_target_group_arn_suffix
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-target-unhealthy" })
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.name_prefix}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is high."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rds-cpu" })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.lambda_function_name != null ? 1 : 0

  alarm_name          = "${var.name_prefix}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Lambda reported one or more errors."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-lambda-errors" })
}

resource "aws_cloudwatch_log_metric_filter" "application_errors" {
  name           = "${var.name_prefix}-application-errors"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ApplicationErrors"
    namespace = "${var.name_prefix}/Application"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "application_errors" {
  alarm_name          = "${var.name_prefix}-application-log-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApplicationErrors"
  namespace           = "${var.name_prefix}/Application"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Application logs contain ERROR entries."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = merge(var.tags, { Name = "${var.name_prefix}-application-log-errors" })
}
