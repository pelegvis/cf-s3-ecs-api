locals {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = local.region
}

module "cf-ecs-s3" {
  source = "./cf-ecs-s3"
  api_image = "821594384510.dkr.ecr.us-east-1.amazonaws.com/flask-demo"
}