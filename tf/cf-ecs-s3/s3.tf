# s3 bucket
resource "aws_s3_bucket" "cf-s3-static-demo-bucket" {
  bucket = "${var.api_name}-${var.region}"
  tags = {
    Name = "${var.api_name}-${var.region}"
    Environment = var.environment
   }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.cf-s3-static-demo-bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "website_bucket_acl" {
  bucket = aws_s3_bucket.cf-s3-static-demo-bucket.id
  acl    = "private"
}


data "aws_iam_policy_document" "cf_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cf-s3-static-demo-bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_s3_bucket_policy" {
  bucket = aws_s3_bucket.cf-s3-static-demo-bucket.id
  policy = data.aws_iam_policy_document.cf_s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "cf_s3_bucket_acl" {
  bucket = aws_s3_bucket.cf-s3-static-demo-bucket.id
  block_public_acls       = true
  block_public_policy     = true
}