# Primary Network Interfaces with 2 private IPs each (1 primary + 1 secondary)
resource "aws_network_interface" "primary" {
  count              = var.instance_count
  subnet_id          = var.subnet_id
  security_groups    = [var.security_group_id]
  private_ips_count  = 2

  tags = {
    Name = "${var.project_name}-eni-primary-${count.index + 1}"
  }
}

# Secondary Network Interfaces with 1 private IP each
resource "aws_network_interface" "secondary" {
  count           = var.instance_count
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = "${var.project_name}-eni-secondary-${count.index + 1}"
  }
}

# EC2 Instances - Simplified: Primary ENI only, secondary attached after
resource "aws_instance" "main" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  monitoring    = false
  
  # Use primary network interface only for launch
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  
  # Disable source/dest check to allow multi-IP routing
  source_dest_check = false

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }

  # Ensure ENIs are created first
  depends_on = [
    aws_network_interface.primary,
    aws_network_interface.secondary
  ]
}

# Attach Primary Network Interfaces to instances (as additional interfaces, not primary)
resource "aws_network_interface_attachment" "primary" {
  count                = var.instance_count
  instance_id          = aws_instance.main[count.index].id
  network_interface_id = aws_network_interface.primary[count.index].id
  device_index         = 1

  depends_on = [aws_instance.main]
}

# Attach Secondary Network Interfaces to instances
resource "aws_network_interface_attachment" "secondary" {
  count                = var.instance_count
  instance_id          = aws_instance.main[count.index].id
  network_interface_id = aws_network_interface.secondary[count.index].id
  device_index         = 2

  depends_on = [aws_network_interface_attachment.primary]
}
