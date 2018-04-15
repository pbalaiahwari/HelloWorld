
#Ec2 instance
resource "aws_instance" "dev"
{
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.dev.name}"]
  count = "${var.count}"
  root_block_device
  {
    volume_type = "gp2"
    volume_size = "30"

  }
  volume_tags
  {
    Name = "volume for dev server"
  }
  user_data = "${file("${var.user_data}")}"
  tags
  {
    Name = "${var.pname}${count.index}"
  }
}


output "ipaddress"
{
  value = "${aws_instance.dev.*.public_ip}"
}
