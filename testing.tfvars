# For the main.tf
aws_access_key="AKIATCHDKKJOYRP2XX4P"
aws_secret_key="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"
region="eu-north-1"


# For launch_configuration
launch_configuration_name = "my-instance-lc"
ami_id               = "ami-0716e5989a4e4fa52"
instance_type        = "t2.micro" 
security_group_id    = module.aws_security_group.web_app_sg.id
key_pair_name        = "my-instance-key" 
user_data_file       = "./user_data_script.sh"

# # For RDS
# db_identifier             = "web_db_example"
# db_engine                 = "mysql"
# db_engine_version         = "8.0.23"
# db_instance_class         = "db.t2.micro"
# db_allocated_storage      = 100
# db_username               = "cloudgen-admin"
# db_password               = "mypassword@2023"
# db_subnet_group_name      = module.db_subnet_group.db_subnet_group_name
# db_vpc_security_group_ids = [module.security_group.security_group_id]
# db_skip_final_snapshot    = true