
module "vpc" {
  source = "../vpc"
}

module "launchconfiguration" {
  source = "../launchconfiguration"
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "web_ec2_asg" {
  name                 = var.autoscaling_group_name
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  desired_capacity      = 2
  launch_configuration = "${module.lauchconfiguration.launch_configuration_name}"
  vpc_zone_identifier  = ["${module.vpc.example_subnet1}", "${module.vpc.example_subnet2}"]

  tag {
    key                 = "autoscaling-group"
    value               = "ec2-group"
    propagate_at_launch = true
  }
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_ec2_asg.id
}
