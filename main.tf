# Define provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

# # Define VPC
#WEB APP VPC
resource "aws_vpc" "web_app_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "db_vpc"
  }
}

#WEB APP SUBNET 1
resource "aws_subnet" "example_subnet1" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet1_cidr_block
  availability_zone = "eu-north-1a"
  tags = {
    Name = "example_subnet1"
  }
}



#WEB APP SUBNET 2
resource "aws_subnet" "example_subnet2" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet2_cidr_block
  availability_zone = "eu-north-1b"

  tags = {
    Name = "example_subnet2"
  }
}

# DB VPC
resource "aws_vpc" "db_vpc" {
  cidr_block = var.vpc_db_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "db_vpc"
  }
}

#DB SUBNET 1
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet1_db_cidr_block
  availability_zone = "eu-north-1a"
  tags = {
    Name = "db_subnet_1"
  }
}

#DB SUBNET 2
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet2_db_cidr_block
  availability_zone = "eu-north-1b"
  tags = {
    Name = "db_subnet_2"
  }
}

## SG for WEB VPC
resource "aws_security_group" "web_app_sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id = aws_vpc.web_app_vpc.id

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

#Internet gateway
resource "aws_internet_gateway" "web_app_igw" {
  vpc_id = aws_vpc.web_app_vpc.id
  tags = {
      Name = "web_app_igw"
    }
}



# Create LoadBalancer
resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_app_sg.id]
  subnets            = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
}


resource "aws_lb_target_group" "web-app-target-group" {
  name     = "web-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_app_vpc.id

  health_check {
    path = "/"
  }
}

# This is optional in case we need LB to HTTP connection request.
resource "aws_lb_listener" "web_app_listener_http" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-target-group.arn
  }
}

#This will be used when domain is generated
# resource "aws_lb_listener" "web_app_listener_https" {
#   load_balancer_arn = aws_lb.web_app_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08" #Subject to change
#   # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"  #Subject to change

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web-app-target-group.arn
#   }
# }

#Launch template
resource "aws_launch_template" "launch_template" {
  name = "my-instance-lt"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  instance_initiated_shutdown_behavior = "terminate"

  image_id       = "ami-0716e5989a4e4fa52"
  instance_type  = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_app_sg.id]
  }

  placement {
    availability_zone = "eu-north-1a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test-ec2-lt"
    }
  }

  user_data = filebase64("${path.module}/user-data-script.sh")
}


#Auto Scaling Group using template
resource "aws_autoscaling_group" "web_ec2_asg" {
  name                 = "auto-scaling-group"
  max_size             = 2
  min_size             = 1
  health_check_grace_period = 300
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "autoscaling-group-key"
    value               = "ec2-group"
    propagate_at_launch = true
  }
}

# # Define RDS within the VPC and all Subnets
# Create RDS Subnet Group
resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
}

# Create RDS Instance
resource "aws_db_instance" "example_db" {
  identifier               = "web-db-example"
  engine                   = "mysql"
  engine_version           = "5.7"
  instance_class           = "db.t3.micro"
  allocated_storage        = 100
  username                 = "cloudgenadmin"
  password                 = "mypassword"
  db_subnet_group_name     = aws_db_subnet_group.example_db_subnet_group.name
  parameter_group_name     = "default.mysql5.7"
  # vpc_security_group_ids   = [aws_vpc.db_vpc]
  skip_final_snapshot      = true
}


output "load_balancer_dns_name" {
  value = aws_lb.web_app_lb.dns_name
}
output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_ec2_asg.id
}
