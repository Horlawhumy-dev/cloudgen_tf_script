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
}

#WEB APP SUBNET 1
resource "aws_subnet" "example_subnet1" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet1_cidr_block
  availability_zone = "eu-north-1a"
}



#WEB APP SUBNET 2
resource "aws_subnet" "example_subnet2" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet2_cidr_block
   availability_zone = "eu-north-1b"
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

resource "aws_internet_gateway" "web_app_igw" {
  vpc_id = aws_vpc.web_app_vpc.id
  tags = {
      Name = "web_app_igw"
    }
}


# # Define LB
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



# Define LC template for AutoScaling
resource "aws_launch_configuration" "web_ec2_lc" {
  name                 ="my-instance-lc"
  image_id             = "ami-0716e5989a4e4fa52"
  instance_type        = "t2.micro" 
  security_groups      = [aws_security_group.web_app_sg.id]
  key_name             = "my-instance-key" 
  user_data            = "./user_data_script.sh"
  # version              = "$Latest"
  lifecycle {
    create_before_destroy = true
  }
}

# # Create Auto Scaling Group
resource "aws_autoscaling_group" "web_ec2_asg" {
  name                 = "auto-scaling-group"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  desired_capacity      = 2
  launch_configuration = aws_launch_configuration.web_ec2_lc.name
  vpc_zone_identifier  = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
  # load_balancer_arn   = aws_lb.web_app_lb.load_balancer_arn
  tag {
    key                 = "autoscaling-group"
    value               = "ec2-group"
    propagate_at_launch = true
  }
}




# # Define RDS within the VPC and all Subnets
# module "rds" {
#   source              = "./modules/rds"
#   vpc_id              = module.vpc.vpc_id
#   subnet_ids          = module.vpc.subnet_ids
# }

output "launch_configuration_name" {
  value = aws_launch_configuration.web_ec2_lc.name
}
output "load_balancer_dns_name" {
  value = aws_lb.web_app_lb.dns_name
}
output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_ec2_asg.id
}
