terraform {
  backend "s3" {
    bucket         = "israel-terraform-state" # using the name of my created bucket
    key            = "state/terraform.tfstate" # this is the path inside my bucket where the state file will be saved
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}