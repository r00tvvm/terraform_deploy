variable "service_name" {
  description = "Servie name"
}

variable "env" {
  description = "Environment (development, staging, production)"
}

variable "aws_region" {
  description = "The AWS region to launch in"
}

variable "public_subnets" {
  type = "list"
}

variable "vpc_id" {
  description = "ID of the VPC to create the Subnets in"
}


