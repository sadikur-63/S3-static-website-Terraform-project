output "static_website_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.s3_website.website_endpoint}"
}