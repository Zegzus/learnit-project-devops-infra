resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

locals {
  servers = {
    app = {
      instance_type     = var.instance_type
      security_group_id = aws_security_group.web_sg.id
      name              = "LearnIT-DevOps-Server"
    }
    monitoring = {
      instance_type     = var.monitoring_instance_type
      security_group_id = aws_security_group.monitoring_sg.id
      name              = "LearnIT-Monitoring-Server"
    }
    jenkins = {
      instance_type     = var.jenkins_instance_type
      security_group_id = aws_security_group.jenkins_sg.id
      name              = "LearnIT-Jenkins-Server"
    }
    jenkins_agent = {
      instance_type     = var.agent_instance_type
      security_group_id = aws_security_group.jenkins_agent_sg.id
      name              = "LearnIT-Jenkins-Agent"
    }
  }
}

resource "aws_instance" "server" {
  for_each = local.servers

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [each.value.security_group_id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = each.value.name
  }
}
