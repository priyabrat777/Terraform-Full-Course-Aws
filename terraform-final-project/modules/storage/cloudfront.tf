resource "aws_cloudfront_origin_access_control" "app" {
  count = var.enable_cloudfront ? 1 : 0

  name                              = "${var.name_prefix}-oac"
  description                       = "Origin access control for ${var.name_prefix} static assets."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "app" {
  count = var.enable_cloudfront ? 1 : 0

  enabled             = true
  default_root_object = "static/index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.this["app"].bucket_regional_domain_name
    origin_id                = "app-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.app[0].id
  }

  default_cache_behavior {
    target_origin_id       = "app-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-cloudfront" })
}

data "aws_iam_policy_document" "cloudfront_app_bucket" {
  count = var.enable_cloudfront ? 1 : 0

  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.this["app"].arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.app[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_app_bucket" {
  count = var.enable_cloudfront ? 1 : 0

  bucket = aws_s3_bucket.this["app"].id
  policy = data.aws_iam_policy_document.cloudfront_app_bucket[0].json
}
