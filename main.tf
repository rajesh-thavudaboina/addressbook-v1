terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
  backend "s3" {
        bucket="tf-state-bucket-v1"
        key="terraform.tfstate"
        region="ap-south-1"
        dynamodb_table="aws-table"
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
  ami           = data.aws_ami.myami.id
  instance_type = var.instance_type

  tags = {
   // Name = "tf-${count.index}"
     Name = "tf-${terraform.workspace}"
  }
}

output "ip" {
  value = aws_instance.web.public_ip
}

output "nwinterface" {
  value = aws_instance.web.primary_network_interface_id
  
}

output "ami" {
  value = aws_instance.web.ami
  
}