output "instances" {
  description = "EC2 instances created"
  value       = aws_instance.main
}

output "secondary_enis" {
  description = "Secondary network interfaces"
  value       = aws_network_interface.secondary
}

output "primary_eips" {
  description = "Primary Elastic IPs"
  value       = aws_eip.primary
}

output "secondary_eips" {
  description = "Secondary Elastic IPs"
  value       = aws_eip.secondary
}

output "instance_details" {
  description = "Comprehensive details of all instances with their IPs"
  value = [
    for idx, instance in aws_instance.main : {
      instance_id          = instance.id
      instance_name        = instance.tags.Name
      availability_zone    = instance.availability_zone
      instance_type        = instance.instance_type
      primary_network_interface_id = instance.primary_network_interface_id

      primary_eni = {
        eni_id      = instance.primary_network_interface_id
        private_ips = instance.private_ips
        eip         = aws_eip.primary[idx].public_ip
        eip_id      = aws_eip.primary[idx].id
      }

      secondary_eni = {
        eni_id     = aws_network_interface.secondary[idx].id
        private_ip = tolist(aws_network_interface.secondary[idx].private_ips)[0]
        eip        = aws_eip.secondary[idx].public_ip
        eip_id     = aws_eip.secondary[idx].id
      }
    }
  ]
}
