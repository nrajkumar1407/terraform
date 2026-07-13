resource "aws_s3_bucket" "file_storage" {
  bucket = "application-file-storage"

  tags = {
    Name = "application-file-storage"
  }
}

resource "aws_dynamodb_table" "application_data" {

  name = "application-data"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"


  attribute {
    name = "id"
    type = "S"
  }


  tags = {
    Name = "application-data"
  }
}
