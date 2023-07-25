# Create Launch Configuration

resource "aws_launch_configuration" "web_ec2_lc" {
  name                 = var.launch_configuration_name
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [var.security_group_id]
  key_name             = var.key_pair_name
  user_data            = filebase64(var.user_data_file)
  version              = "$Latest"
  lifecycle {
    create_before_destroy = true
  }
}

output "launch_configuration_name" {
  value = aws_launch_configuration.web_ec2_lc.name
}
