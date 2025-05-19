provider "aws" {
  region = "eu-west-2"
}


resource "aws_s3_bucket" "bucket_name" {
  bucket = "flipping-bucket-${var.env_name}"

  tags = {
    Name        = "ExampleBucket"
    Environment = var.env_name
  }
}

resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.bucket_name.id
  key    = "my-folder/" # The folder name (must end with a slash)
}

resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.bucket_name.id
  key    = "my-folder/" # The folder name (must end with a slash)
}