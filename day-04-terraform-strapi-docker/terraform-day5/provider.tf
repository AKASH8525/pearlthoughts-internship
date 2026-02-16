terraform {
  backend "s3" {
    bucket  = "pt-terraform-state-akash"
    key     = "strapi-devops/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

