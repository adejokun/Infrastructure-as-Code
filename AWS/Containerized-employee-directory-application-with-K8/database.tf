# create an S3 bucket
resource "aws_s3_bucket" "k8" {
  bucket = "s3-dir-app"
  force_destroy = true
  
  tags = {
    Name        = "s3-dir-app"
    Environment = "dev"
  }
}

# create an S3 bucket - encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "k8" {
  bucket = aws_s3_bucket.k8.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# create a DynamoDB table
resource "aws_dynamodb_table" "k8" {
  name           = "Employees"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"
  

  attribute {
    name = "id"
    type = "S"
  }

    tags = {
    Name        = "Employees"
    Environment = "dev"
  }
}