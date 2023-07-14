resource "aws_vpc" "web_app_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_vpc" "db_vpc" {
  cidr_block = var.vpc_db_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "db_vpc"
  }
}

resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet1_db_cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = "db_subnet_1"
  }
}


resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet2_db_cidr_block
  availability_zone = "us-east-1b"
  tags = {
    Name = "db_subnet_2"
  }
}


resource "aws_subnet" "example_subnet1" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet1_cidr_block
}

resource "aws_subnet" "example_subnet2" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet2_cidr_block
}

## SG for WEB VPC
resource "aws_security_group" "web_app_sg" {
  name        = var.security_group_name
  description = var.security_group_description

  dynamic "ingress" {
    for_each = var.web_security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web_app_sg"
  }
}

## SG for DB VPC
resource "aws_security_group" "db_sg" {
  name = "db_sg"
  description = "AutoScaling EC2 instances security group"
  vpc_id      = aws_vpc.web_app_vpc.id
  ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow traffic to MySQL"
      cidr_blocks = ["10.128.0.0/24"]
    }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
      Name = "db_sg"
    }

}
