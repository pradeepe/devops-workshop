provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ansible_instance" {
  ami           = "ami-04a81a99f5ec58529" # Replace it with the AMI ID for your region
  instance_type = "t2.micro" 
  key_name = "dpp" # Replace with your key pair name
 
  tags = {
    Name = "AnsibleInstance"
  }
 
  user_data = <<-EOF
              #!/bin/bash
              # Update the system
              sudo su -
			        sudo apt update
			        sudo apt install software-properties-common
			        sudo add-apt-repository --yes --update ppa:ansible/ansible
			        sudo apt install ansible
              EOF
  # Security group allowing SSH access
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
 
  # Add an EIP to the instance
  associate_public_ip_address = true
}
 
resource "aws_security_group" "ansible_sg" {
  name        = "ansible_sg"
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
 
output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.ansible_instance.public_ip
}