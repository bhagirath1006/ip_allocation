terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use S3 backend for state management
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "ip-allocation/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = var.environment
      }
    )
  }
}

# EC2 Module - Create 5 instances with multiple network interfaces
module "ec2_instances" {
  source = "./modules/ec2"

  instance_count    = var.instance_count
  instance_type     = var.instance_type
  ami               = var.ami
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id
  project_name      = var.project_name
  environment       = var.environment
}
