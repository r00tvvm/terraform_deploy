resource "aws_elastic_beanstalk_environment" "environment" {
  name          = "${var.service_name}-${var.env}"
  application   = "${var.service_name}"
  cname_prefix  = "${var.service_name}-${var.env}"
  template_name = "${aws_elastic_beanstalk_configuration_template.application_template.name}"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENV"
    value     = "${var.env}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "${var.aws_region}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elastic_beanstalk_configuration_template" "application_template" {
  name                = "${var.service_name}-${var.env}-config"
  application         = "${var.service_name}"
  solution_stack_name = "${var.app_eb_stack}"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${var.eb_service_role}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${var.autoscaling_service_role}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.ec2_instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key_pair_name}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${element(split(",", var.public_subnet_ids), count.index)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "${var.ec2_public_ip}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.ec2_min_instance}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.ec2_max_instance}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "Any 2"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  # ELB settings
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  # Configure the default listener (port 80) on a classic load balancer.
  setting {
    namespace = "aws:elb:listener:80"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:elb:listener:80"
    name      = "ListenerEnabled"
    value     = "true"
  }

  # Modify the default stickiness and global load balancer policies for a classic load balancer.
  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionSettingIdleTimeout"
    value     = "60"
  }

  # Configure a health check path for your application. (ELB Healthcheck)
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "application" {
  value = ["${var.service_name}"]
}

