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

resource "aws_launch_template" "launch_template" {
  name  ="my-instance-lc"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  # capacity_reservation_specification {
  #   capacity_reservation_preference = "open"
  # }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  # credit_specification {
  #   cpu_credits = "standard"
  # }

  # disable_api_stop        = true
  # disable_api_termination = true

  # ebs_optimized = true

  # elastic_gpu_specifications {
  #   type = "test"
  # }

  # elastic_inference_accelerator {
  #   type = "eia1.medium"
  # }

  iam_instance_profile {
    name  = "my-instance-lc"
  }

  instance_initiated_shutdown_behavior = "terminate"

  # instance_market_options {
  #   market_type = "spot"
  # }

  image_id             = "ami-0716e5989a4e4fa52"
  instance_type        = "t2.micro" 

  # kernel_id = "test"

  key_name = "test"

  # license_specification {
  #   license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  # }

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


  # vpc_security_group_ids = [aws_security_group.web_app_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/user-data-script.sh")
}


# Define LC template for AutoScaling
# resource "aws_launch_configuration" "web_ec2_lc" {
#   name                 ="my-instance-lc"
#   image_id             = "ami-0716e5989a4e4fa52"
#   instance_type        = "t2.micro" 
#   security_groups      = [aws_security_group.web_app_sg.id]
#   key_name             = "my-instance-key" 
#   lifecycle {
#     create_before_destroy = true
#   }

  
# }

# # Create Auto Scaling Group
resource "aws_autoscaling_group" "web_ec2_asg" {
  name                 = "auto-scaling-group"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  desired_capacity      = 1
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
# module "rds" {
#   source              = "./modules/rds"
#   vpc_id              = module.vpc.vpc_id
#   subnet_ids          = module.vpc.subnet_ids
# }

# output "launch_configuration_name" {
#   value = aws_launch_configuration.web_ec2_lc.name
# }
output "load_balancer_dns_name" {
  value = aws_lb.web_app_lb.dns_name
}
output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_ec2_asg.id
}
