output "instance_public_ip" {
  description = "Public IP"
  value       = aws_instance.app_server.public_ip
}

output "jenkins_public_ip" {
  description = "Public IP - Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tmpl",
    {
      public_ip = aws_instance.app_server.public_ip
      public_ip_jenkins = aws_instance.jenkins_server.public_ip
    }
  )
  filename = "${path.module}/ansible/inventory.ini"
}
