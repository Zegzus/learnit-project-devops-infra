resource "aws_key_pair" "deployer" {
  key_name   = "learnit-ssh-key"
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
