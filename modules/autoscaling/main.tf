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
  desired_capacity     = 2
  health_check_grace_period = 300
  vpc_zone_identifier  = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  target_group_arns    = [aws_lb_target_group.web-app-target-group.arn]

  tag {
    key                 = "autoscaling-group-key"
    value               = "ec2-group"
    propagate_at_launch = true
  }
}


# resource "aws_autoscaling_group" "web_ec2_asg" {
#   name                 = "auto-scaling-group"
#   max_size             = 2
#   min_size             = 1
#   desired_capacity     = 2
#   health_check_grace_period = 300
#   vpc_zone_identifier  = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]

#   launch_template {
#     id      = aws_launch_template.launch_template.id
#     version = aws_launch_template.launch_template.latest_version
#   }

#   target_group_arns    = [aws_lb_target_group.web-app-target-group.arn]

#   tag {
#     key                 = "autoscaling-group-key"
#     value               = "ec2-group"
#     propagate_at_launch = true
#   }
# }

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_ec2_asg.id
}

