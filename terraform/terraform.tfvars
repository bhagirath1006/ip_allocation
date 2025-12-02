# AWS Resource IDs - Update these with your actual values
# Get these from your AWS Console

# VPC ID where instances will be deployed
# Find at: AWS Console > VPC > Your VPCs
vpc_id = "vpc-xxxxxxxx"

# Subnet ID where instances will be launched
# Find at: AWS Console > VPC > Subnets
subnet_id = "subnet-xxxxxxxx"

# Security Group ID for network access control
# Find at: AWS Console > EC2 > Security Groups
security_group_id = "sg-xxxxxxxx"

# Number of EC2 instances to create (each will have 3 primary + 1 secondary private IPs + 2 public EIPs)
instance_count = 5

# Instance type (t2.micro is free tier eligible)
instance_type = "t2.micro"
