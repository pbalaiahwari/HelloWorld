variable "service_name" {
  type = "string"
  default = "static-web-application"
}

# Create an IAM role with embedded polcy for the beanstalk service

resource "aws_iam_role" "beanstalk_service_role" {
  name = "${var.service_name}-elastic-beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
	  "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

 
resource "aws_iam_policy_attachment" "beanstalk_service" {
  name = "${var.service_name}-elastic-beanstalk-service"
  roles = [
    "${aws_iam_role.beanstalk_service_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

# Attach IAM policy to beanstalk service health 
resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name = "${var.service_name}-elastic-beanstalk-service-health"
  roles = [
    "${aws_iam_role.beanstalk_service_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}


 resource "aws_iam_role" "beanstalk_ec2_role" {
  name = "${var.service_name}-elastic-beanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
  name = "${var.service_name}-elastic-beanstalk-ec2-web"
  roles = [
    "${aws_iam_role.beanstalk_ec2_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.service_name}-beanstalk-ec2-profile"
  role = "${aws_iam_role.beanstalk_ec2_role.name}"
}
resource "aws_iam_instance_profile" "beanstalk_service" {
   name = "${var.service_name}-beanstalk-service-profile"
   role = "${aws_iam_role.beanstalk_service_role.name}"
}
