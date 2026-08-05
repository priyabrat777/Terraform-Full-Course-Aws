data "aws_iam_policy_document" "config_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = "${var.name_prefix}-config-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-config-role" })
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "config_bucket_access" {
  statement {
    actions = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [aws_s3_bucket.audit.arn]
  }

  statement {
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.audit.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
  }
}

resource "aws_iam_role_policy" "config_bucket_access" {
  name   = "${var.name_prefix}-config-bucket-access"
  role   = aws_iam_role.config.id
  policy = data.aws_iam_policy_document.config_bucket_access.json
}

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.name_prefix}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_iam_role_policy_attachment.config]
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.name_prefix}-delivery"
  s3_bucket_name = aws_s3_bucket.audit.id

  depends_on = [aws_config_configuration_recorder_status.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_config_config_rule" "s3_encryption" {
  name = "${var.name_prefix}-s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.main]
}

resource "aws_config_config_rule" "required_tags" {
  name = "${var.name_prefix}-required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Project"
    tag2Key = "Environment"
    tag3Key = "Owner"
  })

  depends_on = [aws_config_configuration_recorder.main]
}
