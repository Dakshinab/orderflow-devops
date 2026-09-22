terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "network" {
  source = "./modules/network"
}

resource "aws_instance" "app" {
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = "t3.small"
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.network.security_group_id]
  key_name                = "orderflow-key"

  tags = {
    Name = "orderflow-server"
  }
}
