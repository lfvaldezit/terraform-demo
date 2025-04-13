
#locals {
#  s3_origin_id = "myS3Origin"
#}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.domain_name
    origin_id = var.origin_id

    custom_origin_config {
      http_port = var.http_port
      https_port = var.https_port
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [ "TLSv1.2" ]
    }
    }

    enabled = var.enabled
    #default_root_object = var.default_root_object

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    default_cache_behavior {
      allowed_methods = [ "GET", "HEAD" ]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = var.origin_id
      viewer_protocol_policy = "allow-all"

      forwarded_values {
        query_string = true
        cookies {
      forward = "all" 
        }
      }
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }
}
