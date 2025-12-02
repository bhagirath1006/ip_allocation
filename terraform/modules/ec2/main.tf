# EC2 Instances with inline network interfaces
resource "aws_instance" "main" {
  count             = var.instance_count
  ami               = var.ami
  instance_type     = var.instance_type
  monitoring        = true
  subnet_id         = var.subnet_id
  security_groups   = [var.security_group_id]
  private_ip_count  = 3

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }
}

# Secondary network interfaces (attached post-launch)
resource "aws_network_interface" "secondary" {
  count           = var.instance_count
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = "${var.project_name}-eni-secondary-${count.index + 1}"
  }
}

# Attach secondary ENI to instances
resource "aws_network_interface_attachment" "secondary" {
  count                = var.instance_count
  instance_id          = aws_instance.main[count.index].id
  network_interface_id = aws_network_interface.secondary[count.index].id
  device_index         = 1

  depends_on = [aws_instance.main]
}

# Elastic IP for Primary Network Interface
resource "aws_eip" "primary" {
  count             = var.instance_count
  domain            = "vpc"
  network_interface = aws_instance.main[count.index].primary_network_interface_id

  tags = {
    Name = "${var.project_name}-eip-primary-${count.index + 1}"
  }

  depends_on = [aws_instance.main]
}

# Elastic IP for Secondary Network Interface
resource "aws_eip" "secondary" {
  count             = var.instance_count
  domain            = "vpc"
  network_interface = aws_network_interface.secondary[count.index].id

  tags = {
    Name = "${var.project_name}-eip-secondary-${count.index + 1}"
  }

  depends_on = [aws_network_interface_attachment.secondary]
}
