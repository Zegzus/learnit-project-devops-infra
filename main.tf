resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name             = aws_key_pair.deployer.key_name

  tags = {
    Name = "LearnIT-DevOps-Server"
  }
}

resource "aws_instance" "monitoring_server" {
  ami           = var.ami_id
  instance_type = var.monitoring_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  key_name             = aws_key_pair.deployer.key_name

  tags = {
    Name = "LearnIT-Monitoring-Server"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = var.ami_id
  instance_type = var.jenkins_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "LearnIT-Jenkins-Server"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami           = var.ami_id
  instance_type = var.agent_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "LearnIT-Jenkins-Agent"
  }
}