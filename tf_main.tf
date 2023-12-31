## CONFIGURE AWS PROVIDER ##
provider "aws" {
  shared_credentials_files = [var.aws_creds_path]
  region = var.aws_region
}


## define aws instance AMI to use 
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

## create Keypair for ssh access
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create key pair for connecting to EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name

  provisioner "local-exec" {
    command = "chmod 400 ${var.key_name}"
  }
}


## Network: subnets and VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default webserver VPC"
  }
}


## Security group
resource "aws_security_group" "main" {
  name        = "Webserver SG"
  description = "Webserver Security Group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


## Create iam instance profile
resource "aws_iam_role" "role" {
  path               = "/"
  assume_role_policy = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Principal": {
                "Service": "ec2.amazonaws.com"
              },
              "Effect": "Allow",
              "Sid": ""
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "profile" {
  role = aws_iam_role.role.name
}

## Create a new host with instance type
resource "aws_instance" "fcx_backend_graphql_api" {
  # ami = data.aws_ami.ubuntu.id
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.name
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  # bootstrap EC2 instance
  # user_data = base64encode(templatefile("${path.module}/tf_dockerwork.sh", { accountId = var.accountId, aws_region = var.aws_region }))
  user_data = <<-EOF
                    #!/bin/bash
                    sudo yum update -y
                    sudo amazon-linux-extras install docker -y
                    sudo service docker start
                    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                    sudo chmod +x /usr/local/bin/docker-compose
                    usermod -a -G docker ec2-user
                    sudo yum install amazon-ecr-credential-helper -y
                    echo '{"credsStore": "ecr-login"}' > ~/.docker/config.json
                    aws --region ${var.aws_region} ecr get-authorization-token
                    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.accountId}.dkr.ecr.${var.aws_region}.amazonaws.com
                  EOF

  tags = {
    Name = "fcx-backend-graphql-api"
  }
}