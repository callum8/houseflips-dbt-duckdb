provider "aws" {
  region = "eu-west-2"
}


resource "aws_s3_bucket" "bucket_name" {
  bucket = "duckdb-dbt-flips-${var.env_name}"

  tags = {
    Name        = "flips-${var.env_name}"
    Environment = var.env_name
  }
}




resource "aws_s3_object" "target_folder" {
  bucket = aws_s3_bucket.bucket_name.id
  key    = "dbt/modelled_data/" # The folder name (must end with a slash)
}

resource "aws_s3_object" "source_folder" {
  bucket = aws_s3_bucket.bucket_name.id
  key    = "dbt/source_data/" # The folder name (must end with a slash)
}

resource "aws_ecr_repository" "flips_ecr" {
  name = "flips-ecr-${var.env_name}"

}


resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<EOT
      docker build -t houseflips-dbt .
      aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 398320704774.dkr.ecr.eu-west-2.amazonaws.com
      docker tag houseflips-dbt:latest 398320704774.dkr.ecr.eu-west-2.amazonaws.com/flips-ecr-dev:latest
      docker push 398320704774.dkr.ecr.eu-west-2.amazonaws.com/flips-ecr-dev:latest
    EOT
  }
}