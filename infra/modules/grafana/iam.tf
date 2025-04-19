resource "aws_iam_role" "grafana_role" {
  name = "grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Read Cloudwatch logs

resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  name        = "grafana-cloudwatch-policy"
  description = "Allows Grafana to access CloudWatch metrics and logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:StartQuery",  # Added this action to allow Grafana to start queries
          "logs:StopQuery",   # Added this action to allow Grafana to stop queries
          "logs:GetQueryResults"  # Added this to allow Grafana to fetch query results
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetrics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmsForMetric"
        ]
        Resource = "*"
      }
    ]
  })
}




# Attach the Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attach" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
}

# Create the IAM Instance Profile
resource "aws_iam_instance_profile" "grafana_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_role.name
}