resource "aws_iam_role" "lambda_role" {
  name = "go_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS Lambda Basic Execution Role Policy
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow lambda to read kinesis stream
resource "aws_iam_policy" "lambda_kinesis_policy" {
  name        = "LambdaKinesisReadPolicy"
  description = "Allows Lambda to read from Kinesis Stream"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListStreams"
        ]
        Resource = var.kinesis_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_attach" {
  policy_arn = aws_iam_policy.lambda_kinesis_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "anomaly_scores_dynamodb_policy" {
  name        = "AnomalyScoresDynamoDBPolicy"
  description = "Policy to allow Lambda to manage anomaly scores in DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
        ]
        Resource = aws_dynamodb_table.anomaly_scores.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "anomaly_scores_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.anomaly_scores_dynamodb_policy.arn
}

# Access Sagemaker
resource "aws_iam_policy" "sagemaker_invoke_policy" {
  name        = "InvokePredictioEndpointPolicy"
  description = "Policy to allow Lambda to invoke prediction endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sagemaker:InvokeEndpoint",
        ]
        Resource = "arn:aws:sagemaker:eu-west-1:730335312484:endpoint/rcf-anomaly-predictor-endpoint"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sagemaker_invoke_policy.arn
}