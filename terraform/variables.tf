variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC ID where instances will be deployed (REQUIRED - provide in terraform.tfvars)"
  type        = string
  default     = ""
  
  validation {
    condition     = length(var.vpc_id) > 0 && strcontains(var.vpc_id, "vpc-")
    error_message = "vpc_id must be provided and must be a valid VPC ID (e.g., vpc-12345678). Create terraform.tfvars with your values."
  }
}

variable "subnet_id" {
  description = "Subnet ID where instances will be deployed (REQUIRED - provide in terraform.tfvars)"
  type        = string
  default     = ""
  
  validation {
    condition     = length(var.subnet_id) > 0 && strcontains(var.subnet_id, "subnet-")
    error_message = "subnet_id must be provided and must be a valid Subnet ID (e.g., subnet-12345678). Create terraform.tfvars with your values."
  }
}

variable "security_group_id" {
  description = "Security group ID for instances (REQUIRED - provide in terraform.tfvars)"
  type        = string
  default     = ""
  
  validation {
    condition     = length(var.security_group_id) > 0 && strcontains(var.security_group_id, "sg-")
    error_message = "security_group_id must be provided and must be a valid Security Group ID (e.g., sg-12345678). Create terraform.tfvars with your values."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 5
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}}

variable "ami" {
  description = "AMI ID for EC2 instances (Amazon Linux 2)"
  type        = string
  default     = "ami-00d2efe5bc0683614" # Amazon Linux 2 in ap-south-1
}

variable "availability_zones" {
  description = "List of availability zones to distribute instances"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ip-allocation"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "ip-allocation"
  }
}
