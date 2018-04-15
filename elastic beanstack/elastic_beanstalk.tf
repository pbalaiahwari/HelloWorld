provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "anil-backend-state"
    key    = "beanstalk/test/terraform.tfstate"
    region = "us-east-1"
  }
}

# creating an elastic bean stalk applicaiton 
resource "aws_elastic_beanstalk_application" "app" {
  name = "${var.service_name}"
}

# Creating a S3 Bucket

resource "aws_s3_bucket" "html" {
  bucket = "${var.bucket_name}"
}

# Uploading object to S3 bucket

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.html.id}"
  key    = "terraformforpeople.zip"
  source = "terraformforpeople.zip"
}

# Mentioning the specific version for the application to use using S3 bucket

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "${var.service_name}-${sha256(file("terraformforpeople.zip"))}"
  application = "${aws_elastic_beanstalk_application.app.id}"
  bucket      = "${aws_s3_bucket.html.id}"
  key         = "${aws_s3_bucket_object.object.id}"
}

# create an environment for the PHP application and configuring resource settings 

resource "aws_elastic_beanstalk_environment" "beanstalk_env" {
  name                = "${var.eb_environment_name}"
  application         = "${aws_elastic_beanstalk_application.app.name}"
  solution_stack_name = "${var.solutions_stack}"
  version_label       = "${aws_elastic_beanstalk_application_version.default.id}"

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "${var.asg_availability_zones}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Cooldown"
    value     = "${var.asg_cooldown}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.asg_minsize}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.asg_maxsize}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"	
    value     = "${aws_iam_instance_profile.ec2_instance_profile.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.ec2_instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.ec2_sg.id}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "MeasureName"
    value = "${var.autoscaling_trigger_measure_name}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Statistic"
    value = "${var.autoscaling_trigger_statistic}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Unit"
    value = "${var.autoscaling_trigger_unit}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Period"
    value = "${var.autoscaling_trigger_period}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "BreachDuration"
    value = "${var.autoscaling_trigger_breach_duration}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperThreshold"
    value = "${var.autoscaling_trigger_upper_threshold}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperBreachScaleIncrement"
    value = "${var.autoscaling_trigger_upper_breach_increment}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerThreshold"
    value = "${var.autoscaling_trigger_lower_threshold}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerBreachScaleIncrement"
    value = "${var.autoscaling_trigger_lower_breach_increment}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.instance_subnets}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${var.elb_subnets}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.beanstalk_service_role.id}"
  }

  setting {
    namespace = "aws:elb:policies"
    name = "ConnectionDrainingEnabled"
    value = "true"
  }
  setting {
    namespace = "aws:elb:policies"
    name = "LoadBalancerPorts"
    value = ":all"
  }
  setting {
    namespace = "aws:elb:policies"
    name = "Stickiness Cookie Expiration"
    value = "${var.elb_sticky_cookie_expiration}"
  }
  setting {
    namespace = "aws:elb:policies"
    name = "Stickiness Policy"
    value = "${var.elb_sticky_policy_enabled}"
  }
  tags {
	Name = "Test-Beanstalk"
	Created_By = "Anil Kumar"
  }
}
variable "eb_environment_name" {}
variable "elb_80_cidr_blocks" {
  type = "list"
}
variable "asg_availability_zones" {
  default = "Any"
}
variable "asg_cooldown" {
  default = "360"  
}
variable "asg_minsize" {}
variable "asg_maxsize" {}
variable "ec2_instance_type" {}
variable "solutions_stack" {
 default = "64bit Amazon Linux 2017.09 v2.6.5 running PHP 7.1"
}
variable "autoscaling_trigger_measure_name" {
  default = "Latency"
}
variable "autoscaling_trigger_statistic" {
  default = "Average"
}
variable "autoscaling_trigger_unit" {
  default = "Seconds"
}
variable "autoscaling_trigger_period" {
  default = "1"
}
variable "autoscaling_trigger_breach_duration" {
  default = "5"
}
variable "autoscaling_trigger_upper_threshold" {
  default = "3"
}
variable "autoscaling_trigger_upper_breach_increment" {
  default = "1"
}
variable "autoscaling_trigger_lower_threshold" {
  default = "1"
}
variable "autoscaling_trigger_lower_breach_increment" {
  default = "-1"
}
variable "vpc_id" {}
variable "instance_subnets" {} 
variable "elb_subnets" {}   
variable "elb_sticky_policy_enabled" {
  default = "false"
}

variable "aws_access_key" {
  type = "string"
}

variable "aws_secret_key" {
  type = "string"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
}

variable "s3_bucket" {
 default = "sampleapp-test-bucket"
}

variable "bucket_name" {
 default = "anil-terraform"
 }
variable "elb_sticky_cookie_expiration" {
 default = "600"
 }
