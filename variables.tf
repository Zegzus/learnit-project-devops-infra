variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 22.04 LTS AMI ID"
  default     = "ami-053b0d53c279acc90"
}
