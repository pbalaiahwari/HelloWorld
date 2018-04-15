output "example-elb" {
	value = "${aws_elb.example-elb.dns_name}"
}

output "example-1" {
  value = "${aws_instance.example-1.public_ip}"
}

output "example-2" {
  value = "${aws_instance.example-2.public_ip}"
}

output "example-3" {
  value = "${aws_instance.example-3.public_ip}"
}

