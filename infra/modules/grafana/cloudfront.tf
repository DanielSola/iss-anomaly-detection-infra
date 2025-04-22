resource "aws_cloudfront_distribution" "grafana" {
  origin {
    domain_name = aws_instance.grafana.public_dns
    origin_id   = "grafana-origin"

    custom_origin_config {
      http_port              = 3000
      https_port             = 443
      origin_protocol_policy = "http-only"  # EC2 only speaks HTTP on 3000
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = ""  # Grafana handles routing

default_cache_behavior {
  allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
  cached_methods   = ["GET", "HEAD"]
  target_origin_id = "grafana-origin"

  forwarded_values {
    query_string = true
    headers      = ["*"]

    cookies {
      forward = "all"
    }
  }

  viewer_protocol_policy = "redirect-to-https"
}


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # Use the free default CloudFront cert
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}
