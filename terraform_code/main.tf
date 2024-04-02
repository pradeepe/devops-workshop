provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_instance" "demo-server" {
    ami = "ami-0eb5115914ccc4bc2"
    instance_type = "t2.micro"
    key_name = "dpp"
}

resource "aws_security_group" "demo-SG" {
  name        = "demo-sg"
  description = "SSH Access"
  
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
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
    Name = "ssh-port"
  }
}