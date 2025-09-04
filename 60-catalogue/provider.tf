terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

    backend "s3" {
      #changed  key
    bucket         = "mahalakshmi-remote-state-dev"  # Replace with your S3 bucket name
    key            = "roboshop-dev-catalogue" # Replace with your desired state file path/name
    region         = "us-east-1"                   # Replace with your AWS region
    encrypt        = true                          # Enables server-side encryption for the state file
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}