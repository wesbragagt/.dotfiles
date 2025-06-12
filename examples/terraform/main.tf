# This file is just meant to be used to test the lsp for terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "my-test-bucket"  
}
