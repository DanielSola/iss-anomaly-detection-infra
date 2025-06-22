resource "aws_iam_policy" "kinesis_policy" {
  name        = "KinesisWritePolicy"
  description = "Allows writing to Kinesis"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "kinesis:PutRecord"
      Resource = "arn:aws:kinesis:${var.aws_region}:${var.aws_account_id}:stream/iss-data-stream"
    }]
  })
}
