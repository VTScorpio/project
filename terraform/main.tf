terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

# key-pair SSH
resource "aws_key_pair" "main_key" {
  key_name   = "main-key-local"
  public_key = file(var.public_key_path)
}

# Grup de securitate
resource "aws_security_group" "monitor_sg" {
  name        = "monitor-sg"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instanta EC2 instance 
resource "aws_instance" "monitor_vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.monitor_sg.id]

  tags = {
    Name = "monitor"
  }
}