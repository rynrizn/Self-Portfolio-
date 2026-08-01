data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# OAC firma las solicitudes de CloudFront a S3 con SigV4.
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${local.resource_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"

  tags = local.common_tags

  # Mejor cobertura global, incluidas Sudamérica, Asia-Pacífico y Australia.
  price_class = "PriceClass_All"

  origin {
    # El endpoint REST permite mantener el bucket privado mediante OAC.
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.site.id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.site.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Usa HTTPS en el dominio predeterminado de CloudFront.
    cloudfront_default_certificate = true
  }
}
