provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0eb5115914ccc4bc2"
    instance_type = "t2.micro"
    key_name = "dpp"
}