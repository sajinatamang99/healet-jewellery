output "public_ip" {
  value       = aws_instance.webserver.public_ip
  description = "Public IP of the EC2 instance"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = values(aws_subnet.public_subnets)[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.demo_sg.id
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
  sensitive   = true
}
