terraform {
  backend "s3" {
    bucket         = "hcl-hackathon-terraform-state-pavanbl"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-pavanbl"
    encrypt        = true
    acl            = "bucket-owner-full-control"
  }
}
