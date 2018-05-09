variable "service_name" {
  description = "Application name"
}

variable "env" {}

variable "aws_region" {}

variable "vpc_id" {
  description = "VPC id "
}

variable "public_subnet_ids" {
  type        = "string"
  description = "Public subnet ids list"
}

/*
variable "aws_region" {
  description = "AWS region"
}
*/
# https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
variable "app_eb_stack" {
  description = "Elasticbealstalk application stack"
}

variable "ec2_instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type"
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
  default     = "false"
  description = "EC2 instances must have a public ip (true | false)"
}

variable "ssh_key_pair_name" {
  description = "AWS EC2 ssh key pair name"
}

variable "eb_service_role" {
  description = "AWS Elasticbeanstalk service role"
}

variable "autoscaling_service_role" {
  default     = "AWSServiceRoleForAutoScaling"
  description = "AWS Services and Resources that are used or managed by Auto Scaling. Service-Linked Roles."
}

variable "healthcheck_url" {
  type        = "string"
  default     = "HTTP:80/"
  description = "path to which to send health check requests."
}
