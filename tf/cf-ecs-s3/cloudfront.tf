resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.s3_origin_id
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.s3_origin_id
  default_root_object = "index.html"
  
  origin {
    domain_name = aws_alb.my_api.dns_name
    origin_id   = local.api_origin_id
    custom_origin_config {
      http_port              = 80
      origin_protocol_policy = "http-only"
      https_port = 443
      origin_ssl_protocols = ["TLSv1"]
    }
  }
  origin {
    domain_name = aws_s3_bucket.cf-s3-static-demo-bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id  
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "/v1/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.api_origin_id
    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "all"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
  viewer_certificate {
  cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }
}

output "cloudfront_dns" {
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}