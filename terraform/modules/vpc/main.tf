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
