# resource "aws_s3_bucket" "bucket" {
#   bucket = myCloudresume

#   force_destroy = true
# }
# resource "aws_s3_bucket_website_configuration" "website_configuration" {
#   bucket = aws_s3_bucket.bucket.id
#   index_document {
#     suffix = "index.html"
#   }
#   error_document {
#     key = "error.html"
#   }
# }
# resource "aws_s3_bucket_public_access_block" "public_access_block" {
#   bucket = aws_s3_bucket.bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # resource "aws_s3_object" "upload_object" {
# #   for_each      = fileset("${path.module}/../html", "*")
# #   bucket        = aws_s3_bucket.bucket.bucket
# #   key           = each.value
# #   source        = "${path.module}/../html/${each.value}"
# #   etag          = filemd5("${path.module}/../html/${each.value}")
# #   content_type  = "text/html"
# # }

# # resource "aws_s3_bucket_policy" "read_access_policy" {
# #   bucket = aws_s3_bucket.bucket.id
# #   policy = <<POLICY
# # {
# #   "Version": "2012-10-17",
# #   "Statement": [
# #     {
# #       "Sid": "PublicReadGetObject",
# #       "Effect": "Allow",
# #       "Principal": "*",
# #       "Action": [
# #         "s3:GetObject"
# #       ],
# #       "Resource": [
# #         "${aws_s3_bucket.bucket.arn}",
# #         "${aws_s3_bucket.bucket.arn}/*"
# #       ]
# #     }
# #   ]
# # }
# # POLICY
# # }
#   data "aws_iam_policy_document" "bucket_policy" {
#     statement {
#       sid = var.sid
#       effect = "Allow"

#       principals {
#         type = "Service"
#         identifiers = ["cloudfront.amazonaws.com"]
#       }

#       actions = [
#         "s3:GetObject"
#       ]

#       resources = var.resource

#       condition {
#         test = "StringEquals"
#         variable = "AWS:SourceArn"
#         values = [ var.cloudfront_distribution_arn ]
#       }
#     }
#   }
#     resource "aws_cloudfront_distribution" "s3_distribution" {
#     origin {
#       domain_name              = var.bucket_regional_domain_name
#       origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#       origin_id                = var.origin_id
#     }

#     enabled             = true
#     is_ipv6_enabled     = true
#     comment             = var.comment
#     default_root_object = var.default_root_object

#     default_cache_behavior {
#       allowed_methods  = var.allowed_methods
#       cached_methods   = var.cached_methods
#       target_origin_id = var.origin_id

#       forwarded_values {
#         query_string = var.query_string

#         cookies {
#           forward = var.cookies_forward
#         }
#       }

#       viewer_protocol_policy = var.viewer_protocol_policy
#       min_ttl                = var.min_ttl
#       default_ttl            = var.default_ttl
#       max_ttl                = var.max_ttl
#     }

#     price_class = var.price_class

#     restrictions {
#       geo_restriction {
#         restriction_type = var.restriction_type
#         locations        = var.locations
#       }
#     }

#     viewer_certificate {
#       cloudfront_default_certificate = true
#     }
#   }


#   resource "aws_s3_bucket_policy" "bucket_policy" {
#     bucket = var.bucket_name
#     policy = data.aws_iam_policy_document.bucket_policy.json
#   }
#     resource "aws_cloudfront_origin_access_control" "default" {
#     name                              = var.name
#     description                       = var.description
#     origin_access_control_origin_type = var.origin_access_control_origin_type
#     signing_behavior                  = var.signing_behavior
#     signing_protocol                  = var.signing_protocol
#   }
#     module "s3_website_config" {
#     source = "../aws/s3/s3_website_configuration"

#     sid                         = var.bucket_policy_sid
#     bucket_name                 = module.bucket.id
#     cloudfront_distribution_arn = module.cloudfront_distribution.arn
#     resource                    = ["${module.bucket.arn}/*"]
#   }
#     module "cloudfront_distribution" {
#     source = "../aws/cloudfront_distribution"

#     name                        = var.name
#     description                 = var.description
#     comment                     = var.comment
#     bucket_regional_domain_name = module.bucket.bucket_regional_domain_name
#     origin_id                   = var.origin_id
#   }



