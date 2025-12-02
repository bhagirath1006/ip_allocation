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

# EC2 Instances - created without any network interfaces initially
resource "aws_instance" "main" {
  count                = var.instance_count
  ami                  = var.ami
  instance_type        = var.instance_type
  monitoring           = true
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  # Disable primary ENI to use custom one
  associate_public_ip_address = false

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }

  depends_on = [
    aws_network_interface.primary
  ]

  lifecycle {
    ignore_changes = [network_interface]
  }
}

# Attach primary network interface
resource "aws_network_interface_attachment" "primary" {
  count                = var.instance_count
  instance_id          = aws_instance.main[count.index].id
  network_interface_id = aws_network_interface.primary[count.index].id
  device_index         = 0

  depends_on = [aws_instance.main]
}

# Attach secondary network interface
resource "aws_network_interface_attachment" "secondary" {
  count                = var.instance_count
  instance_id          = aws_instance.main[count.index].id
  network_interface_id = aws_network_interface.secondary[count.index].id
  device_index         = 1

  depends_on = [aws_network_interface_attachment.primary]
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

  depends_on = [aws_network_interface_attachment.secondary]
}
