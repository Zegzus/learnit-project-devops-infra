variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "jenkins_instance_type" {
  type        = string
  default     = "t3.small"
}

variable "agent_instance_type" {
  type        = string
  description = "Instance type for the dedicated Jenkins build agent"
  default     = "t3.small"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 24.04 LTS AMI ID"
  default     = "ami-042dc8681de073ac4"
}

variable "key_name" {
  type        = string
  description = "Name assigned to the generated AWS key pair"
  default     = "learnit-ssh-key"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR allowed to SSH into the instances. Restrict this to your own IP (e.g. \"1.2.3.4/32\") instead of leaving it open to the world."
  default     = "0.0.0.0/0"
}
