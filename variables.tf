variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 24.04 LTS AMI ID"
  default     = "ami-042dc8681de073ac4"
}

variable "key_name" {
  type        = string
  description = "Name of the AWS SSH key pair"
  default     = "key-name-in-aws"
}
