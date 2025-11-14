terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }
    bluecat = {
      source  = "bluecatlabs/bluecat"
      version = "1.1.1"
    }
  }
  backend "s3" {
    region               = "us-east-2"
    bucket               = "network-pipeline-global-artifacts-us-east-2"
    workspace_key_prefix = "terraform/aws-cloudwatch-monitor"
    key                  = "terraform.tfstate"
    dynamodb_table       = "network-pipeline-global-state-locks"
    endpoints = {
      dynamodb = "https://dynamodb.us-east-2.amazonaws.com"
    }
    assume_role = {
      role_arn = "arn:aws:iam::364637677316:role/network-pipeline-service-role"
    }
  }
}

provider "aws" {
  alias  = "net104-gnts-np-use1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::676063845817:role/network-pipeline-service-role"
  }
}

provider "aws" {
  alias  = "net101-gnts-pr-us-east-1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::676063845817:role/network-pipeline-service-role"
  }
}
provider "aws" {
  alias  = "net101-gnts-pr-us-east-2"
  region = "us-east-2"
  assume_role {
    role_arn = "arn:aws:iam::676063845817:role/network-pipeline-service-role"
  }
}
provider "aws" {
  alias  = "net101-gnts-pr-eu-central-1"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::676063845817:role/network-pipeline-service-role"
  }
}
provider "aws" {
  alias  = "net101-gnts-pr-ap-southeast-1"
  region = "ap-southeast-1"
  assume_role {
    role_arn = "arn:aws:iam::676063845817:role/network-pipeline-service-role"
  }
}