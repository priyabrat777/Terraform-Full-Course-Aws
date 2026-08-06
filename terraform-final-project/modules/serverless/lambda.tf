data "archive_file" "lambda" {
  count = var.enabled ? 1 : 0

  type        = "zip"
  source_file = "${path.root}/scripts/lambda_processor.py"
  output_path = "${path.root}/.terraform/${var.name_prefix}-lambda.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  count = var.enabled ? 1 : 0

  name               = "${var.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-lambda-role" })
}

data "aws_iam_policy_document" "lambda" {
  count = var.enabled ? 1 : 0

  statement {
    sid = "WriteLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.lambda[0].arn}:*"]
  }

  statement {
    sid       = "ReadSourceBucket"
    actions   = ["s3:GetObject"]
    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    sid       = "WriteDestinationBucket"
    actions   = ["s3:PutObject"]
    resources = ["${var.destination_bucket_arn}/*"]
  }

  statement {
    sid       = "UseQueue"
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.events[0].arn]
  }

  statement {
    sid       = "DecryptApplicationData"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "lambda" {
  count = var.enabled ? 1 : 0

  name   = "${var.name_prefix}-lambda-policy"
  role   = aws_iam_role.lambda[0].id
  policy = data.aws_iam_policy_document.lambda[0].json
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enabled ? 1 : 0

  name              = "/aws/lambda/${var.name_prefix}-processor"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = merge(var.tags, { Name = "${var.name_prefix}-lambda-logs" })
}

resource "aws_lambda_function" "processor" {
  count = var.enabled ? 1 : 0

  function_name    = "${var.name_prefix}-processor"
  role             = aws_iam_role.lambda[0].arn
  handler          = "lambda_processor.handler"
  runtime          = var.lambda_runtime
  filename         = data.archive_file.lambda[0].output_path
  source_code_hash = data.archive_file.lambda[0].output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  kms_key_arn      = var.kms_key_arn

  environment {
    variables = {
      DESTINATION_BUCKET = var.destination_bucket_id
      LOG_LEVEL          = "INFO"
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda,
    aws_cloudwatch_log_group.lambda
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-processor" })
}

resource "aws_lambda_permission" "allow_s3" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.source_bucket_arn
}

resource "aws_s3_bucket_notification" "source" {
  count = var.enabled ? 1 : 0

  bucket = var.source_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count = var.enabled ? 1 : 0

  event_source_arn = aws_sqs_queue.events[0].arn
  function_name    = aws_lambda_function.processor[0].arn
  batch_size       = 10
  enabled          = true
}
