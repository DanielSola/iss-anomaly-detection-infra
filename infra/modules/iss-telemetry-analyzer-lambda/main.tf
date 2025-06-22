# Local build of Lambda binary and zip
resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p lambda_build
      cd lambda_build
      rm -rf iss-telemetry-analyzer
      git clone https://github.com/DanielSola/iss-telemetry-analyzer.git
      cd iss-telemetry-analyzer
      go mod tidy
      GOARCH=amd64 GOOS=linux go build -o bootstrap main.go
      zip ../iss-telemetry-analyzer.zip bootstrap
    EOT
  }
}


# Upload Lambda package to S3
resource "aws_s3_object" "lambda_package" {
  bucket     = "iss-telemetry-analyzer-lambda"
  key        = "iss-telemetry-analyzer.zip"
  source     = "lambda_build/iss-telemetry-analyzer.zip"
  depends_on = [null_resource.build_lambda]
}


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
  depends_on  = [aws_s3_object.lambda_package]
  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = "rcf-anomaly-predictor-endpoint"
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}
