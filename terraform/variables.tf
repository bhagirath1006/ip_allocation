variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "create_vpc" {
  description = "Whether to create a new VPC. Set to false to use existing VPC."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Existing VPC ID to use (required if create_vpc is false)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Existing subnet ID to use (required if create_vpc is false)"
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "Existing security group ID to use (required if create_vpc is false)"
  type        = string
  default     = ""
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 5
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "AMI ID for EC2 instances (Amazon Linux 2)"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1
}

variable "availability_zones" {
  description = "List of availability zones to distribute instances"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
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
