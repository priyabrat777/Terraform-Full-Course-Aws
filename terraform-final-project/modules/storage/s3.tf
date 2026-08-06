resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  buckets = {
    app = {
      purpose = "application"
      kms_arn = var.kms_key_arn
    }
    artifacts = {
      purpose = "artifacts"
      kms_arn = var.kms_key_arn
    }
    logs = {
      purpose = "logs"
      kms_arn = var.log_kms_key_arn
    }
  }

  static_files = fileset("${path.root}/examples/static-site", "**/*")
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    txt  = "text/plain"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket = substr("${var.name_prefix}-${each.key}-${random_id.bucket_suffix.hex}", 0, 63)

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${each.key}"
    Purpose = each.value.purpose
  })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.buckets[each.key].kms_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.this["logs"].id

  rule {
    id     = "expire-old-log-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_object" "static_site" {
  for_each = { for file in local.static_files : file => file }

  bucket       = aws_s3_bucket.this["app"].id
  key          = "static/${each.value}"
  source       = "${path.root}/examples/static-site/${each.value}"
  etag         = filemd5("${path.root}/examples/static-site/${each.value}")
  content_type = lookup(local.content_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
