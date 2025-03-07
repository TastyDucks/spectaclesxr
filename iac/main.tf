provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "spectaclesxr-terraform-state"
    key            = "spectaclesxr/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    dynamodb_table = "spectaclesxr-terraform-lock"
  }
}
