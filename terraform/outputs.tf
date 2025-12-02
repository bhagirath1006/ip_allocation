output "instances" {
  description = "Details of all EC2 instances"
  value = {
    for idx, instance in module.ec2_instances.instances : "instance_${idx + 1}" => {
      instance_id         = instance.id
      primary_eni_id      = instance.primary_network_interface_id
      secondary_eni_id    = module.ec2_instances.secondary_enis[idx].id
      private_ips_primary = module.ec2_instances.primary_enis[idx].private_ips
      primary_eip         = module.ec2_instances.primary_eips[idx].public_ip
      secondary_eip       = module.ec2_instances.secondary_eips[idx].public_ip
    }
  }
}

output "instance_summary" {
  description = "Summary of all instances with IPs"
  value = [
    for idx, instance in module.ec2_instances.instances : {
      name        = "instance-${idx + 1}"
      instance_id = instance.id
      private_ips = instance.primary_network_interface_id
      public_eips = [
        module.ec2_instances.primary_eips[idx].public_ip,
        module.ec2_instances.secondary_eips[idx].public_ip
      ]
      az = instance.availability_zone
    }
  ]
}

output "vpc_id" {
  description = "VPC ID"
  value       = var.create_vpc ? aws_vpc.main[0].id : var.vpc_id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value       = var.create_vpc ? aws_subnet.public[0].id : var.subnet_id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.main.id
}
