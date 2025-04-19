resource "aws_iam_policy" "delete_sagemaker_endpoint_policy" {
  name        = "DeleteSagemakerEndpoint"
  description = "Policy to delete of sagemaker endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sagemaker:DeleteEndpoint"
        ]
        Resource = "arn:aws:sagemaker:eu-west-1:730335312484:endpoint/rcf-anomaly-predictor-endpoint"
      }
    ]
  })
}