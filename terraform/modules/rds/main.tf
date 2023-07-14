# Create RDS Subnet Group

resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
}


# Create RDS Instance
resource "aws_db_instance" "example_db" {
  identifier               = var.db_identifier
  engine                   = var.db_engine
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  allocated_storage        = var.db_allocated_storage
  username                 = var.db_username
  password                 = var.db_password
  db_subnet_group_name     = var.db_subnet_group_name
  vpc_security_group_ids   = var.db_vpc_security_group_ids
  skip_final_snapshot      = var.db_skip_final_snapshot
}
