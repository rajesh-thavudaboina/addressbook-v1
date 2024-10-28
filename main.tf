terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
  #   access_key = "my-access-key"
  #   secret_key = "my-secret-key"
}

variable "instance_type"{

}

data "aws_ami" "myami"{
  most_recent = true
#  virtualization_type = "hvm"
  filter{
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  
 
  filter{
    name="virtualization-type"
    values = ["hvm"]
  }
  

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.myami.id
  instance_type = var.instance_type

  tags = {
    Name = "tf-${count.index}"
  }
}

output "ip" {
  value = aws_instance.web[0].public_ip
}

output "nwinterface" {
  value = aws_instance.web[0].primary_network_interface_id
  
}

output "ami" {
  value = aws_instance.web[0].ami
  
}