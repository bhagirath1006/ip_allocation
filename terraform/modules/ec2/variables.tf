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
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instances will be deployed (REQUIRED)"
  type        = string
  
  validation {
    condition     = length(var.subnet_id) > 0 && strcontains(var.subnet_id, "subnet-")
    error_message = "subnet_id must be a valid subnet ID (e.g., subnet-12345678). Please provide this in terraform.tfvars."
  }
}

variable "security_group_id" {
  description = "Security group ID for instances (REQUIRED)"
  type        = string
  
  validation {
    condition     = length(var.security_group_id) > 0 && strcontains(var.security_group_id, "sg-")
    error_message = "security_group_id must be a valid security group ID (e.g., sg-12345678). Please provide this in terraform.tfvars."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
