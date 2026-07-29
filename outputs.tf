output "instance_public_ip" {
  description = "Public IP"
  value       = aws_instance.app_server.public_ip
}
