provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-public-subnet-01" {
  vpc_id     = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-west-1a"
  tags = {
    Name = "dpp-public-subnet-01"
  }
}

resource "aws_subnet" "dpp-public-subnet-02" {
  vpc_id     = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-west-1b"
  tags = {
    Name = "dpp-public-subnet-02"
  }
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id     = aws_vpc.dpp-vpc.id

  tags = {
    Name = "dpp-igw"
  }
}


resource "aws_route_table" "dpp-public-rt" {
    vpc_id     = aws_vpc.dpp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }

  tags = {
    Name = "dpp-public-rt"
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