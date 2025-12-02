# AWS Resource IDs - Your actual values
vpc_id = "vpc-0ed9e59c3d9a8c9f5"

# Using second subnet for deployment
subnet_id = "subnet-0384e2e784fb94bde"

# Security group for EC2 instances
security_group_id = "sg-039578fd8eed8b2ce"

# Number of EC2 instances to create (each will have 3 primary + 1 secondary private IPs + 2 public EIPs)
instance_count = 5

# Instance type (t2.micro is free tier eligible)
instance_type = "t2.micro"
