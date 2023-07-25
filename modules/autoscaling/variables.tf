variable "autoscaling_group_name" {
    description = "AutoScaling Group"
  
}

variable "launch_configuration_name" {
  description = "Launch configuration name"
}

variable "ami_id" {
  description = "AMI ID"
}

variable "instance_type" {
  description = "Instance type"
}

variable "security_group_id" {
  description = "Security group ID"
}

variable "key_pair_name" {
  description = "Key pair name"
}

variable "user_data_file" {
  type    = list(string)
  description = "User data script file path"
  default = ["./modules/autoscaling/user_data_script.sh"]
}

