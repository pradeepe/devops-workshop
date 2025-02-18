provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-public-subnet-01" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dpp-public-subent-01"
  }
}

resource "aws_subnet" "dpp-public-subnet-02" {
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

resource "aws_route_table" "dpp-public-rt" {
  vpc_id = aws_vpc.dpp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id 
  }
}

resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
  subnet_id = aws_subnet.dpp-public-subnet-01.id
  route_table_id = aws_route_table.dpp-public-rt.id   
}

resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
  subnet_id = aws_subnet.dpp-public-subnet-02.id 
  route_table_id = aws_route_table.dpp-public-rt.id   
}

resource "aws_instance" "ansible-server" {
# Replace it with the AMI ID for your region ami-0427090fd1714168b for AWS Linux ami-04a81a99f5ec58529
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro" 
  key_name = "dpp" # Replace with your key pair name
 //security_groups = [ "demo-sg" ]
  vpc_security_group_ids = [aws_security_group.ansible-sg.id]
  subnet_id = aws_subnet.dpp-public-subnet-01.id 

  tags = {
     Name = "DevOps-Ansible-Server"
  }

    user_data = <<-EOF
              #!/bin/bash
              # Update the system
              #yum update -y
              sudo apt update
 
              # Install required packages
              # yum install -y python3 python3-pip
              sudo apt install software-properties-common
 
              # Install Ansible
              # pip3 install ansible
              sudo add-apt-repository --yes --update ppa:ansible/ansible
              sudo apt install ansible
 
              # Verify Ansible installation
              ansible --version
              EOF

  # Security group allowing SSH access
  # vpc_security_group_ids = [aws_security_group.demo_sg]
 
  # Add an EIP to the instance
  associate_public_ip_address = true
}

resource "aws_security_group" "ansible-sg" {
  name        = "ansible_sg"
  description = "Allow SSH inbound traffic for Ansible Server"
  vpc_id = aws_vpc.dpp-vpc.id

  tags = {
    Name = "ansible-sg-SSH"
  }
 
  ingress {
    description = "Shh access for Ansible Server"
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
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "instance_public_ip" {
  description = "The public IP of the EC2 Ansible instance"
  value       = aws_instance.ansible-server.public_ip
}

resource "aws_instance" "jenkins-server" {
# Replace it with the AMI ID for your region ami-0427090fd1714168b for AWS Linux ami-04a81a99f5ec58529
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro" 
  key_name = "dpp" # Replace with your key pair name
 //security_groups = [ "jenkins-sg" ]
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  subnet_id = aws_subnet.dpp-public-subnet-01.id 

  tags = {
     Name = "DevOps-Jenkins-Server"
  }

  # Security group allowing SSH access
  # vpc_security_group_ids = [aws_security_group.jenkins_sg]
 
  # Add an EIP to the instance
  associate_public_ip_address = true
}

resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins_sg"
  description = "Allow SSH inbound traffic for Jenkins Server"
  vpc_id = aws_vpc.dpp-vpc.id

  tags = {
    Name = "jenkins-sg-SSH"
  }
 
  ingress {
    description = "Shh access for Jenkins Server"
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
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "build-server" {
# Replace it with the AMI ID for your region ami-0427090fd1714168b for AWS Linux ami-04a81a99f5ec58529
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro" 
  key_name = "dpp" # Replace with your key pair name
 //security_groups = [ "build-sg" ]
  vpc_security_group_ids = [aws_security_group.build-sg.id]
  subnet_id = aws_subnet.dpp-public-subnet-01.id 
 
  tags = {
     Name = "DevOps-Build-Server"
  }

  # Security group allowing SSH access
  # vpc_security_group_ids = [aws_security_group.build_sg]
 
  # Add an EIP to the instance
  associate_public_ip_address = true
}

resource "aws_security_group" "build-sg" {
  name        = "build_sg"
  description = "Allow SSH inbound traffic for Build Server"
  vpc_id = aws_vpc.dpp-vpc.id

  tags = {
    Name = "build-sg-SSH"
  }
 
  ingress {
    description = "Shh access for build Server"
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
    ipv6_cidr_blocks = ["::/0"]
  }
}

#output "instance_public_ip" {
#  description = "The public IP of the Build server EC2 instance"
#  value       = aws_instance.build-server.public_ip
#}