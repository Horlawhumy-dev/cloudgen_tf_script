# Scalable and Secure Web Application Architecture

This Terraform script sets up an AWS environment with an auto-scaling EC2 setup behind a load balancer and an RDS instance. The script automates the creation of the infrastructure required to run a web application, ensuring secure communication between the load balancer and the RDS instance.

## Prerequisites
Before executing the Terraform script, make sure you have the following prerequisites:

## Terraform installed on your machine.
AWS access key and secret access key with appropriate permissions to create resources (EC2, RDS, VPC, etc.).
Your SSH key pair for accessing the EC2 instances as well.


## Instructions
1. To set up the AWS environment, follow these steps:

2. Clone the repository or create a new directory for your Terraform files.

3. Place the Terraform script (main.tf and variables.tf) in the global directory.

Open the main.tf file and replace the placeholder values with your actual AWS credentials, desired configurations, and customize any other values to fit your requirements. Make sure to update the following values:

* `YOUR_AWS_ACCESS_KEY` and `YOUR_AWS_SECRET_ACCESS_KEY` with your AWS access key and secret access key.
* Set the desired AWS region in the `provider` block (`region` parameter).
* Customize the VPC CIDR block, subnet CIDR blocks, security group rules, load balancer settings, EC2 instance settings, RDS instance settings, etc.

4. Create a user data script for your EC2 instances. This script is provided as base64 encoded data in the user_data attribute of the aws_launch_configuration resource. Replace the user-data.sh file with your own script or modify it according to your application requirements.

5. Open a terminal or command prompt and navigate to the directory containing the Terraform files.

6. Run the following command to initialize Terraform and download the necessary providers:
```bash
terraform init
```

7. Run the following command to preview the resources that will be created:
```bash
terraform plan
```

8. Review the output to ensure that the planned infrastructure matches your requirements.

If the preview looks correct, run the following command to create the AWS environment using the variables file:
```bash
terraform apply -var-file="testing.tfvars"
```

Confirm the action by typing "yes" when prompted.

Terraform will create the VPC, subnets, security groups, load balancer, launch configuration, auto scaling group, RDS subnet group, and RDS instance.

9. Once the command completes, the AWS environment is set up and ready for use. The load balancer DNS name will be displayed as the output.

10. Congratulations and do not hesitate to reach out if any issue encoutered. 
`harof.dev@gmail.com`


