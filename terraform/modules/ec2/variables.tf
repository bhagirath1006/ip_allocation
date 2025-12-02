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
  description = "Subnet ID where instances will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
