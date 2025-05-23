resource "aws_dynamodb_table" "anomaly_scores" {
  name           = "AnomalyScores"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "key"

  attribute {
    name = "key"
    type = "S"
  }
}
