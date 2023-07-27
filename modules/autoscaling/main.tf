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

