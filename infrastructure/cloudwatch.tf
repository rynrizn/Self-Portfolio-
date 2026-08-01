resource "aws_cloudwatch_dashboard" "site" {
  dashboard_name = "${local.resource_name}-dashboard"

  dashboard_body = jsonencode({
    start          = "-PT3H"
    periodOverride = "inherit"

    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "CloudFront requests"
          region = "us-east-1"
          view   = "timeSeries"
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/CloudFront",
              "Requests",
              "DistributionId", aws_cloudfront_distribution.site.id,
              "Region", "Global",
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "CloudFront downloaded bytes"
          region = "us-east-1"
          view   = "timeSeries"
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/CloudFront",
              "BytesDownloaded",
              "DistributionId", aws_cloudfront_distribution.site.id,
              "Region", "Global",
            ],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          title  = "CloudFront error rates"
          region = "us-east-1"
          view   = "timeSeries"
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/CloudFront",
              "4xxErrorRate",
              "DistributionId", aws_cloudfront_distribution.site.id,
              "Region", "Global",
              { label = "4xx" },
            ],
            [
              "AWS/CloudFront",
              "5xxErrorRate",
              "DistributionId", aws_cloudfront_distribution.site.id,
              "Region", "Global",
              { label = "5xx" },
            ],
          ]
        }
      },
    ]
  })
}
