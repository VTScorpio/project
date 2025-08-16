variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-12345678"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_pair_name" {
  default = "main-key-local"
}

variable "public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}

variable "s3_bucket_name" {
  default = "project-terraform-state-local"
}
