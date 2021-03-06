
variable "aws_access_key" {}
variable "aws_secret_key" {}
 
variable "service_name" {
  description = "Application environment name"
}

variable "env" {
  default     = "development"
  description = "Environment (development, staging, production)"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Subnet parameters
variable "public_subnets" {
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "The public subnet CIDR blocks"
}

# VPC parameters
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

# Elacticbeanstalk application settings
variable "app_eb_stack" {
  default     = "64bit Amazon Linux 2017.09 v2.6.6 running PHP 7.0"
  description = "Elasticbealstalk application stack https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html"
}

variable "ec2_instance_type" {
  default     = "t2.micro"
  description = "The EC2 instance type"
}

variable "ec2_min_instance" {
  default     = "1"
  description = "Minimum instance number"
}

variable "ec2_max_instance" {
  default     = "2"
  description = "Maximum instance number"
}

variable "ec2_public_ip" {
  default     = "true"
  description = "EC2 instances must have a public ip (true | false)"
}

variable "ssh_key_pair_name" {
  description = "AWS EC2 ssh key pair name"
}

variable "eb_service_role" {
  #default     = "aws-elasticbeanstalk-service-role"
  default     = "AWSServiceRoleForAutoScaling"
  description = "AWS Elasticbeanstalk service role"
}

variable "autoscaling_service_role" {
  default     = "aws-elasticbeanstalk-ec2-role"
  description = "AWS Services and Resources Auto Scaling Role, Service-Linked Role"
}
