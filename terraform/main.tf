# Define provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#Amazon AMI
data "aws_ami" "ami-amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get VPC id of default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "default" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "Default subnet for us-east-1"
  }
}

# Create Amazon Linux EC2 instance
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ami-amzn2.id
  key_name               = aws_key_pair.assignment.key_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  user_data = "${file("docker_script.sh")}"
  tags = {
    Name = "LinuxServer-EC2"
    }
}

resource "aws_security_group" "sg1" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Http"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "Http"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh"
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
  }
  tags = {
    Name = "allow_http"
  }
}

# Adding SSH key
resource "aws_key_pair" "assignment" {
  key_name   = "assignment"
  public_key = file("assignment.pub")
}

# ECR Repository
resource "aws_ecr_repository" "assignment1-ecr" {
  name                 = "assignment1-ecr"
  image_tag_mutability = "MUTABLE"
}