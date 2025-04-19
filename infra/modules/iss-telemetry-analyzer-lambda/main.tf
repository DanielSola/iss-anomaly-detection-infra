resource "aws_lambda_function" "iss_telemetry_analyzer" {
  function_name = "iss-telemetry-analyzer-lambda"
  s3_bucket     = "iss-telemetry-analyzer-lambda"
  s3_key        = "iss-telemetry-analyzer.zip"
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  role          = aws_iam_role.lambda_role.arn
 # source_code_hash = aws_s3_object.lambda_package.etag
  timeout     = var.timeout
  memory_size = var.memory_size
  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = "rcf-anomaly-predictor-endpoint"
    }
  }
}
