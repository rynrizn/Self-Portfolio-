output "s3_bucket_name" {
  description = "Generated S3 bucket name used by the deployment system."
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "Use to invalidate CloudFront after deployments."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_url" {
  description = "Public HTTPS URL assigned by CloudFront."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}
