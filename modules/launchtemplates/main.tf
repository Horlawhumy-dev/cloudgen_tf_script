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