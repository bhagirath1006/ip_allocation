output "instances" {
  description = "EC2 instances created"
  value       = aws_instance.main
}

output "primary_enis" {
  description = "Primary network interfaces"
  value       = aws_network_interface.primary
}

output "secondary_enis" {
  description = "Secondary network interfaces"
  value       = aws_network_interface.secondary
}

output "instance_details" {
  description = "Comprehensive details of all instances with their IPs"
  value = [
    for idx, instance in aws_instance.main : {
      instance_id       = instance.id
      instance_name     = instance.tags.Name
      availability_zone = instance.availability_zone
      instance_type     = instance.instance_type

      primary_eni = {
        eni_id      = aws_network_interface.primary[idx].id
        private_ips = sort(aws_network_interface.primary[idx].private_ips)
      }

      secondary_eni = {
        eni_id     = aws_network_interface.secondary[idx].id
        private_ip = tolist(aws_network_interface.secondary[idx].private_ips)[0]
      }
    }
  ]
}
