data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "EnableRootAccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "AllowCommonAWSServiceUse"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
        "dynamodb.amazonaws.com",
        "elasticfilesystem.amazonaws.com",
        "lambda.amazonaws.com",
        "logs.${data.aws_region.current.name}.amazonaws.com",
        "rds.amazonaws.com",
        "s3.amazonaws.com",
        "sns.amazonaws.com",
        "sqs.amazonaws.com"
      ]
    }
  }
}

resource "aws_kms_key" "this" {
  for_each = var.keys

  description             = "${var.name_prefix} ${each.value.description}"
  deletion_window_in_days = each.value.deletion_window_in_days
  enable_key_rotation     = each.value.enable_key_rotation
  policy                  = data.aws_iam_policy_document.kms.json

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${each.key}-key"
    Purpose = each.key
  })
}

resource "aws_kms_alias" "this" {
  for_each = aws_kms_key.this

  name          = "alias/${var.name_prefix}-${each.key}"
  target_key_id = each.value.key_id
}
