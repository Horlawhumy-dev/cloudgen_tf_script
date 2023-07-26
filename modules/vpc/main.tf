# Define provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

#WEB APP VPC
resource "aws_vpc" "web_app_vpc" {
  cidr_block = var.vpc_cidr_block
   tags = {
    Name = "web_app_vpc"
  }
}

#WEB APP SUBNET 1
resource "aws_subnet" "example_subnet1" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet1_cidr_block

  tags = {
    Name = "example_subnet1"
  }
}



#WEB APP SUBNET 2
resource "aws_subnet" "example_subnet2" {
  vpc_id     = aws_vpc.web_app_vpc.id
  cidr_block = var.subnet2_cidr_block

  tags = {
    Name = "example_subnet1"
  }
}


# DB VPC
resource "aws_vpc" "db_vpc" {
  cidr_block = var.vpc_db_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "db_vpc"
  }
}


## SG for DB VPC
# resource "aws_security_group" "db_sg" {
#   name = "db_sg"
#   description = "AutoScaling EC2 instances security group"
#   vpc_id      = aws_vpc.web_app_vpc.id
#   ingress {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       description = "Allow traffic to MySQL"
#       cidr_blocks = ["10.128.0.0/24"]
#     }
#   egress {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   tags = {
#       Name = "db_sg"
#     }

# }




## Peering connection between web_app_vpc and db_vpc
resource "aws_vpc_peering_connection" "web_app_db_peering" {
#   peer_owner_id = var.peer_owner_id #Defaults to AWS ID
  peer_vpc_id   = aws_vpc.web_app_vpc.id
  vpc_id        = aws_vpc.db_vpc.id
  auto_accept   = true
  tags = {
    Name = "web_vpc_app_db_peering"
  }
}

# Create an Elastic IP address for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Create the NAT Gateway using the Elastic IP
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.example_subnet1.id
}

# Create a route table for the private subnet and associate it with the VPC peering connection
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.db_vpc.id

    #For Outboun Traffic
  route {
    cidr_block = "0.0.0.0/0"
    # Assuming there is a NAT gateway in the private subnet to access the internet
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  route {
    cidr_block = aws_vpc.web_app_vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.web_app_db_peering.id
  }
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "db_subnet_association" {
  subnet_id      = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.db_route_table.id
}

#DB SUBNET 1
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet1_db_cidr_block
  availability_zone = "eu-north-1a"
  
  tags = {
    Name = "db_subnet_1"
  }
}

#DB SUBNET 2
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.db_vpc.id 
  cidr_block        = var.subnet2_db_cidr_block
  availability_zone = "eu-north-1b"
  
  tags = {
    Name = "db_subnet_2"
  }
}


# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_sg"

  vpc_id = aws_vpc.db_vpc.id

  # Add inbound rules to allow traffic from the public VPC
  ingress {
    from_port   = 3306 # Assuming MySQL port, change it if using a different DB engine
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.web_app_vpc.cidr_block]
  }

  tags = {
    Name = "db_sg"
  }
}



## Route for APP
resource "aws_route_table" "web_app_rt" {
  vpc_id = aws_vpc.web_app_vpc.id
  route {
      cidr_block                = "10.240.0.0/16"
      vpc_peering_connection_id = aws_vpc_peering_connection.web_app_db_peering.id
    }
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.web_app_igw.id
    }
  tags = {
      Name = "web_app_rt"
    }
}



## Route for DB
# resource "aws_route_table" "db_rt" {
#   vpc_id = aws_vpc.web_app_vpc.id
#   route {
#       cidr_block                = "10.128.0.0/16"
#       vpc_peering_connection_id = aws_vpc_peering_connection.web_app_db_peering.id
#     }
#   tags = {
#       Name = "db_rt"
#     }
# }


## Route Table - Subnet Associations for Web App and DB
# resource "aws_route_table_association" "web_app_rta2" {
#   subnet_id      = aws_subnet.example_subnet1.id
#   route_table_id = aws_route_table.web_app_rt.id
# }
# resource "aws_route_table_association" "db_rta1" {
#   subnet_id      = aws_subnet.db_subnet_1.id
#   route_table_id = aws_route_table.db_rt.id
# }
# resource "aws_route_table_association" "db_rta2" {
#   subnet_id      = aws_subnet.db_subnet_2.id
#   route_table_id = aws_route_table.db_rt.id
# }

## SG for WEB VPC
resource "aws_security_group" "web_app_sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id = aws_vpc.web_app_vpc.id

  dynamic "ingress" {
    for_each = var.web_security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web_app_sg"
  }
}

#Internet gateway
resource "aws_internet_gateway" "web_app_igw" {
  vpc_id = aws_vpc.web_app_vpc.id
  tags = {
      Name = "web_app_igw"
    }
}
## SG for DB VPC
# resource "aws_security_group" "db_sg" {
#   name = "db_sg"
#   description = "AutoScaling EC2 instances security group"
#   vpc_id      = aws_vpc.web_app_vpc.id
#   ingress {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       description = "Allow traffic to MySQL"
#       cidr_blocks = ["10.128.0.0/24"]
#     }
#   egress {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   tags = {
#       Name = "db_sg"
#     }

# }



output "example_subnet1" {
  value = aws_subnet.example_subnet1
}

output "example_subnet2" {
  value = aws_subnet.example_subnet2
}

output "web_app_sg" {
  value = [aws_security_group.web_app_sg.name, aws_security_group.web_app_sg.name]
}

