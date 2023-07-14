resource "aws_vpc" "example_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "example_subnet1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = var.subnet1_cidr_block
}

resource "aws_subnet" "example_subnet2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = var.subnet2_cidr_block
}

resource "aws_security_group" "example_sg" {
  name        = var.security_group_name
  description = var.security_group_description

  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

## SG for DB VPC
resource "aws_security_group" "db_sg" {
  name = "db_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.example_vpc.id
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
