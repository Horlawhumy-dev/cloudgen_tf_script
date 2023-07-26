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