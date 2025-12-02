output "instances" {
  description = "Details of all EC2 instances with their IP configuration"
  value = {
    for idx, instance in module.ec2_instances.instances : "instance_${idx + 1}" => {
      instance_id          = instance.id
      instance_name        = instance.tags.Name
      instance_type        = instance.instance_type
      availability_zone    = instance.availability_zone
      primary_eni_id       = module.ec2_instances.primary_enis[idx].id
      primary_private_ips  = sort(module.ec2_instances.primary_enis[idx].private_ips)
      secondary_eni_id     = module.ec2_instances.secondary_enis[idx].id
      secondary_private_ip = tolist(module.ec2_instances.secondary_enis[idx].private_ips)[0]
    }
  }
}

output "instance_summary" {
  description = "Summary of all instances with their IP addresses"
  value = [
    for idx, instance in module.ec2_instances.instances : {
      name              = "instance-${idx + 1}"
      instance_id       = instance.id
      instance_type     = instance.instance_type
      availability_zone = instance.availability_zone
      primary_ips       = sort(module.ec2_instances.primary_enis[idx].private_ips)
      secondary_ip      = tolist(module.ec2_instances.secondary_enis[idx].private_ips)[0]
      total_private_ips = concat(
        sort(module.ec2_instances.primary_enis[idx].private_ips),
        tolist(module.ec2_instances.secondary_enis[idx].private_ips)
      )
    }
  ]
}

output "vpc_id" {
  description = "VPC ID used for instances"
  value       = var.vpc_id
}

output "subnet_id" {
  description = "Subnet ID used for instances"
  value       = var.subnet_id
}

output "security_group_id" {
  description = "Security Group ID used for instances"
  value       = var.security_group_id
}
