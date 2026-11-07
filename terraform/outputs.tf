output "vpc_id" {
  description = "ID of the dedicated VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "application_url" {
  description = "Web URL to access the deployed frontend on HTTP port 80"
  value       = "http://${aws_instance.app_server.public_ip}"
}

