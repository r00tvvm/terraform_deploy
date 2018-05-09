provider "aws" {
  region                  = "${var.aws_region}"
}

module "vpc" {
  #source     = "github.com/BasileTrujillo/terraform-elastic-beanstalk-nodejs//eb-env"
  source       = "../modules/vpc"
  service_name = "${var.service_name}-vpc"
  env          = "${var.env}"
  vpc_cidr     = "${var.vpc_cidr}"
}

module "subnets" {
  source       = "../modules/public_subnets"
  service_name = "${var.service_name}-public-subnet"
  env          = "${var.env}"

  # Network parameters
  public_subnets = "${var.public_subnets}"
  vpc_id         = "${module.vpc.vpc_id}"
  aws_region     = "${var.aws_region}"
}

module "s3bucket" {
  source = "../modules/s3"

  service_name = "${var.service_name}"
  env          = "${var.env}"
}

module "application" {
  source = "../modules/application"

  # Application settings
  service_name = "${var.service_name}"
  env          = "${var.env}"
  aws_region   = "${var.aws_region}"
  app_eb_stack = "${var.app_eb_stack}"

  # Network settings
  vpc_id            = "${module.vpc.vpc_id}"
  public_subnet_ids = "${module.subnets.public_subnets_ids}"

  # Instance settings
  ec2_instance_type = "${var.ec2_instance_type}"
  ec2_min_instance = "${var.ec2_min_instance}"
  ec2_max_instance = "${var.ec2_max_instance}"
  ec2_public_ip    = "${var.ec2_public_ip}"

  ssh_key_pair_name = "${var.ssh_key_pair_name}"

  eb_service_role          = "${var.eb_service_role}"
  autoscaling_service_role = "${var.autoscaling_service_role}"

  healthcheck_url = "HTTP:80/"

  #public_subnets = "${var.public_subnets}"
  #aws_region     = "${var.aws_region}"
}
