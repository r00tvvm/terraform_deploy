provider "aws" {
  region                  = "${var.aws_region}"
}

variable "application_name" {
  description = "Elasticbeanstalk global application name "
}

resource "aws_elastic_beanstalk_application" "application" {
  name = "${var.application_name}"

  lifecycle {
    create_before_destroy = true
  }
}
