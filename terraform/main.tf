terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "5.82.2"
   }
 }
}
provider "aws" {
 # Configuration options
 region = "ap-south-1"
}

# resource "aws_vpc" "ownvpc" {
#   cidr_block = "10.0.0.0/16"
#   tags={
#     Name="own-vpc"
#   }
# }

# module "myserver-subnet" {
#   source = "./modules/subnet"
#   vpc_id = aws_vpc.ownvpc.id
#   subnet_cidr_block = var.subnet_cidr_block
#   az = var.az
# }

module "myserver-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.ownvpc.id
  subnet_id = module.myserver-subnet.subnet.id
  instance_type = var.instance_type
}