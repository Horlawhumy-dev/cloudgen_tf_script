# Create Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  name                 = var.autoscaling_group_name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  launch_configuration = var.launch_configuration_name
  vpc_zone_identifier  = var.vpc_zone_identifiers

  tag {
    key                 = var.tag_name
    value               = var.tag_value
    propagate_at_launch = true
  }
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.example_asg.id
}
