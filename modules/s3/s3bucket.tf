variable "service_name" {
  description = "Application environment name"
}

variable "env" {
  default     = "development"
  description = "Environment (development, staging, production)"
}


resource "aws_s3_bucket" "application_bucket" {
  bucket        = "${var.service_name}-${var.env}-deployments"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags {
    Name        = "${var.service_name}"
    Environment = "${var.env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
