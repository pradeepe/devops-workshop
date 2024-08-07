provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-pub-subnet-01" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dpp-public-subent-01"
  }
}

resource "aws_subnet" "dpp-pub-subnet-02" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "dpp-public-subent-02"
  }
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id 
  tags = {
    Name = "dpp-igw"
  } 
}

resource "aws_route_table" "dpp-pub-rt" {
  vpc_id = aws_vpc.dpp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id 
  }
}

resource "aws_route_table_association" "dpp-rta-pub-subnet-01" {
  subnet_id = aws_subnet.dpp-pub-subnet-01.id
  route_table_id = aws_route_table.dpp-pub-rt.id   
}

resource "aws_route_table_association" "dpp-rta-pub-subnet-02" {
  subnet_id = aws_subnet.dpp-pub-subnet-02.id 
  route_table_id = aws_route_table.dpp-pub-rt.id   
}

resource "aws_instance" "ansible_instance" {
  ami           = "ami-0427090fd1714168b" # Replace it with the AMI ID for your region ami-0427090fd1714168b for AWS Linux ami-04a81a99f5ec58529
  instance_type = "t2.micro" 
  key_name = "dpp" # Replace with your key pair name
 
  tags = {
    Name = "DevOps-Ansible"
  }

    user_data = <<-EOF
              #!/bin/bash
              # Update the system
              yum update -y
 
              # Install required packages
              yum install -y python3 python3-pip
 
              # Install Ansible
              pip3 install ansible
 
              # Verify Ansible installation
              ansible --version
              EOF

  # Security group allowing SSH access
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
 
  # Add an EIP to the instance
  associate_public_ip_address = true
}
 
resource "aws_security_group" "ansible_sg" {
  name        = "ansible_sg"
  description = "Allow SSH inbound traffic"

  tags = {
    Name = "Ansiansible-sg-SSH"
  }
 
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
 
output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.ansible_instance.public_ip
}