resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-26-10-2026"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
  depends_on = [aws_s3_bucket.example] # adding this change to ensure the S3 bucket is created before the VPC
}