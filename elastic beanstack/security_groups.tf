resource "aws_security_group" "ec2_sg" {

  name = "${var.service_name}-ec2_sg"
  vpc_id = "${var.vpc_id}"

  tags {
	Name = "test-beanstalk-sg"
	Created_By = "Anil Kumar"
  }
}

resource "aws_security_group_rule" "http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2_sg.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = "${var.elb_80_cidr_blocks}"
}
