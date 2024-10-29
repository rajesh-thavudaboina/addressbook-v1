terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
  # backend "s3" {
  #       bucket="tf-state-bucket-v1"
  #       key="terraform.tfstate"
  #       region="ap-south-1"
  #       dynamodb_table="aws-table"
  #   }

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
// vpc
resource "aws_vpc" "ownvpc" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name="own-vpc"
  }
}
//subnet
resource "aws_subnet" "ownsubnet" {
  vpc_id     = aws_vpc.ownvpc.id
  cidr_block = "10.0.1.0/24"
availability_zone="ap-south-1b"


  tags = {
    Name = "own-subnet"
  }
}

//igw

resource "aws_internet_gateway" "ownigw" {
  vpc_id = aws_vpc.ownvpc.id


  tags = {
    Name = "own-igw"
  }
}

//route table

resource "aws_route_table" "ownrt" {
  vpc_id = aws_vpc.ownvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ownigw.id
  }
  tags={
    Name: "own-rt"
  }
}

# 5) associate rt
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.ownsubnet.id
  route_table_id = aws_route_table.ownrt.id
}

resource "aws_security_group" "mywebsecurity" {
  name        = "ownsecurityrules"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.ownvpc.id
 
   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }
  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "own-sg"
  }
}


resource "aws_instance" "webserver" {
  ami           = data.aws_ami.myami.id
  instance_type = var.instance_type
   
   associate_public_ip_address =true
   subnet_id=aws_subnet.ownsubnet.id
   vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
   key_name="aws"
   user_data=file("server-script.sh")
   
  tags = {
    Name = "mywebserver"
  }
}


output "ip" {
  value = aws_instance.webserver.public_ip
}

output "nwinterface" {
  value = aws_instance.webserver.primary_network_interface_id
  
}

output "ami" {
  value = aws_instance.webserver.ami
  
}