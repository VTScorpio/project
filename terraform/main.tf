terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
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

resource "aws_key_pair" "main_key" {
  key_name   = "main-key-local"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "monitor_vm" {
  ami                         = "ami-12345678"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.main_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "monitor"
  }
}
