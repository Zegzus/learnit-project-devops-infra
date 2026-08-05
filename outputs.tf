output "instance_public_ip" {
  description = "Public IP"
  value       = aws_instance.app_server.public_ip
}

output "monitoring_public_ip" {
  description = "Public IP"
  value       = aws_instance.monitoring_server.public_ip
}

output "jenkins_public_ip" {
  description = "Public IP - Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_agent_public_ip" {
  description = "Public IP - Jenkins build agent"
  value       = aws_instance.jenkins_agent.public_ip
}

output "app_private_ip" {
  value = aws_instance.app_server.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring_server.private_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins_server.private_ip
}

output "agent_private_ip" {
  value = aws_instance.jenkins_agent.private_ip
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tmpl",
    {
      public_ip = aws_instance.app_server.public_ip
      private_ip = aws_instance.app_server.private_ip
      public_ip_monitoring = aws_instance.monitoring_server.public_ip
      private_ip_monitoring = aws_instance.monitoring_server.private_ip
      public_ip_jenkins = aws_instance.jenkins_server.public_ip
      private_ip_jenkins = aws_instance.jenkins_server.private_ip
      public_ip_agent = aws_instance.jenkins_agent.public_ip
      private_ip_agent = aws_instance.jenkins_agent.private_ip
    }
  )
  filename = "${path.module}/ansible/inventory.ini"
}
