provider "aws" {
  region = "us-west-1"
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
