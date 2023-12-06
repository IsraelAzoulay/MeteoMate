# Terraform Backend Configuration for State Management
terraform {
  backend "s3" {
    bucket         = "israel-terraform-state" # S3 bucket for storing the Terraform state
    key            = "state/terraform.tfstate" # Path to the state file inside the bucket
    region         = "us-east-1" # AWS region for the S3 bucket
    dynamodb_table = "terraform-state-lock" # DynamoDB table for state locking
    encrypt        = true # Enable encryption for the state file
  }
}