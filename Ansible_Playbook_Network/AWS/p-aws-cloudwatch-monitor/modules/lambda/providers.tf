terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.34.0"
      configuration_aliases = [aws.main]
    }
  }
}