# Create Launch Configuration

module "launch_configuration" {
  source               = "./modules/launch_configuration"
  launch_configuration_name = "example-lc"
  ami_id               = "ami-12345678"  # Set the desired AMI ID
  instance_type        = "t2.micro"      # Set the desired instance type
  security_group_id    = aws_security_group.example_sg.id
  key_pair_name        = "example-key"   # Set the desired key pair
  user_data_file       = "user-data.sh"  # Specify the path to your user data script
}