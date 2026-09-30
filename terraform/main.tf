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

resource "aws_iam_role" "app_role" {
  name = "orderflow-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "sqs_access" {
  name = "orderflow-sqs-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "arn:aws:sqs:ap-south-1:*:orderflow-order-queue"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "orderflow-app-profile"
  role = aws_iam_role.app_role.name
}

resource "aws_instance" "app" {
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = "t3.small"
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.network.security_group_id]
  key_name               = "orderflow-key"
  iam_instance_profile   = aws_iam_instance_profile.app_profile.name

  tags = {
    Name = "orderflow-server"
  }
}
