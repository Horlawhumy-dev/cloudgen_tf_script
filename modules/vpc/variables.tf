variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret access key"
}

variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}



variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr_block" {
  description = "CIDR block for subnet 1"
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr_block" {
  description = "CIDR block for subnet 2"
  default     = "10.0.2.0/24"
}


variable "vpc_db_cidr_block" {
  description = "CIDR block for the DB VPC"
 default     = "172.31.0.0/16"
}

variable "subnet1_db_cidr_block" {
  description = "CIDR block for DB subnet"
  default     = "172.31.1.0/24"
}

variable "subnet2_db_cidr_block" {
  description = "CIDR block for DB subnet"
  default     = "172.31.2.0/24"
}


variable "security_group_name" {
  description = "Name of the security group"
  default     = "web-app-sg"
}

variable "security_group_description" {
  description = "Description of the security group"
  default     = "Example Security Group"
}

variable "web_security_group_ingress_rules" {
  description = "Ingress rules for the security group"
  type        = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from my Public IP"
      cidr_blocks = ["0.0.0.0/32"]
    },
    {
      from_port   = 80 
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  default     = "db-subnet-group"
}