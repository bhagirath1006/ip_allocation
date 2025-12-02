output "instances" {
  description = "Details of all EC2 instances"
  value = {
    for idx, instance in module.ec2_instances.instances : "instance_${idx + 1}" => {
      instance_id           = instance.id
      primary_eni_id        = instance.primary_network_interface_id
      secondary_eni_id      = instance.network_interfaces[1]
      private_ips_primary   = instance.primary_network_interface_id
      primary_eip           = module.ec2_instances.primary_eips[idx]
      secondary_eip         = module.ec2_instances.secondary_eips[idx]
    }
  }
}

output "instance_summary" {
  description = "Summary of all instances with IPs"
  value = [
    for idx, instance in module.ec2_instances.instances : {
      name              = "instance-${idx + 1}"
      instance_id       = instance.id
      private_ips       = instance.primary_network_interface_id
      public_eips       = [
        module.ec2_instances.primary_eips[idx].public_ip,
        module.ec2_instances.secondary_eips[idx].public_ip
      ]
      az                = instance.availability_zone
    }
  ]
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.main.id
}
