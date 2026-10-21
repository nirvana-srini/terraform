terraform {
  backend "s3" {
    bucket = "dev-terraform-state-backend-bucket-21102026-1"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
