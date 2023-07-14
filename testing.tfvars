# For the main.tf
aws_access_key=""
aws_secret_access_key=""
region=""

# For launch_configuration
launch_configuration_name = "example-lc"
ami_id               = "ami-12345678"  # Set the desired AMI ID
instance_type        = "t2.micro"      # Set the desired instance type
security_group_id    = aws_security_group.example_sg.id
key_pair_name        = "example-key"   # Set the desired key pair
user_data_file       = "./modules/launchconfiguration/user_data_script.sh"

# For RDS
db_identifier             = "example-db"
db_engine                 = "mysql"
db_engine_version         = "8.0.23"
db_instance_class         = "db.t2.micro"
db_allocated_storage      = 20
db_username               = "admin"
db_password               = "examplepassword"
db_subnet_group_name      = module.db_subnet_group.db_subnet_group_name
db_vpc_security_group_ids = [module.security_group.security_group_id]
db_skip_final_snapshot    = true