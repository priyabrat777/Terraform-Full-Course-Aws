resource "aws_sqs_queue" "events" {
  count = var.enabled ? 1 : 0

  name                       = "${var.name_prefix}-events"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = var.lambda_timeout * 2
  kms_master_key_id          = var.kms_key_arn

  tags = merge(var.tags, { Name = "${var.name_prefix}-events" })
}
