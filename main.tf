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

# # Define VPC
module "vpc" {
  source              = "./modules/vpc"
  region              = var.region
}

# # Define LB
# module "load_balancer" {
#   source              = "./modules/load_balancer"
#   vpc_id              = module.vpc.vpc_id
# }

# # Define LC template for AutoScaling
# module "launch_configuration" {
#   source               = "./modules/launchconfiguration"
# }


# # Define AutoScaling
# module "autoscaling" {
#   source              = "./modules/autoscaling"
#   vpc_zone_identifier = module.vpc.subnet_ids
#   load_balancer_arn   = module.load_balancer.load_balancer_arn
# }


# # Define RDS within the VPC and all Subnets
# module "rds" {
#   source              = "./modules/rds"
#   vpc_id              = module.vpc.vpc_id
#   subnet_ids          = module.vpc.subnet_ids
# }
