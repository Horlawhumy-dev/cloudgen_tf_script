# Create RDS Subnet Group

resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
}

resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example_sg.id]
  subnets            = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
}

output "load_balancer_dns_name" {
  value = aws_lb.example_lb.dns_name
}
