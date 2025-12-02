# Primary Network Interfaces with 3 private IPs each (1 primary + 2 secondary)
resource "aws_network_interface" "primary" {
  count           = var.instance_count
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  # 1 primary + 2 secondary private IPs
  private_ips_count = 3

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

# EC2 Instances
resource "aws_instance" "main" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  monitoring    = true

  # Attach primary network interface
  network_interface {
    network_interface_id = aws_network_interface.primary[count.index].id
    device_index         = 0
  }

  # Attach secondary network interface
  network_interface {
    network_interface_id = aws_network_interface.secondary[count.index].id
    device_index         = 1
  }

  # Disable source/dest check to allow IP forwarding (optional)
  source_dest_check = false

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }

  depends_on = [
    aws_network_interface.primary,
    aws_network_interface.secondary
  ]
}

# Elastic IPs for Primary Network Interfaces
resource "aws_eip" "primary" {
  count             = var.instance_count
  domain            = "vpc"
  network_interface = aws_network_interface.primary[count.index].id

  tags = {
    Name = "${var.project_name}-eip-primary-${count.index + 1}"
  }

  depends_on = [aws_instance.main]
}

# Elastic IPs for Secondary Network Interfaces
resource "aws_eip" "secondary" {
  count             = var.instance_count
  domain            = "vpc"
  network_interface = aws_network_interface.secondary[count.index].id

  tags = {
    Name = "${var.project_name}-eip-secondary-${count.index + 1}"
  }

  depends_on = [aws_instance.main]
}
