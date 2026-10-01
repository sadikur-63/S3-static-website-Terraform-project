resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. S3 Bucket
resource "aws_s3_bucket" "s3_website" {
  bucket = "terraform-course-project-1-${random_id.bucket_suffix.hex}"
}

# 2. Disable S3 Block Public Access
resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.s3_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Attach Public Read Bucket Policy
resource "aws_s3_bucket_policy" "static_website_public_read" {
  bucket     = aws_s3_bucket.s3_website.id
  depends_on = [aws_s3_bucket_public_access_block.allow_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.s3_website.arn}/*"
      }
    ]
  })
}

# 4. Enable Static Website Hosting Configuration
resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = aws_s3_bucket.s3_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 5. Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.s3_website.id
  key          = "index.html"
  source       = "${path.module}/build/index.html"
  etag         = filemd5("${path.module}/build/index.html")
  content_type = "text/html"
}

# 6. Upload error.html
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.s3_website.id
  key          = "error.html"
  source       = "${path.module}/build/error.html"
  etag         = filemd5("${path.module}/build/error.html")
  content_type = "text/html"
}