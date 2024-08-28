# create an S3 bucket
resource "aws_s3_bucket" "dir-app" {
  bucket = "s3-dir-app"
  force_destroy = true
  
  tags = {
    Name        = "s3-dir-app"
    Environment = "dev"
  }
}

# create an S3 bucket - encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dir-app" {
  bucket = aws_s3_bucket.dir-app.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# create a DynamoDB table
resource "aws_dynamodb_table" "dir-app" {
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