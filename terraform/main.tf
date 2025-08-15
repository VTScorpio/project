provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "dev_key" {
  key_name   = "dev_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "monitor_vm" {
  ami                    = "ami-0c02fb55956c7d316"  # Ubuntu 22.04 (us-east-1)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.dev_key.key_name

  user_data              = file("user_data.sh")

  tags = {
    Name = "Monitor-DevOps"
  }
}
