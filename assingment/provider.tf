# Define the provider
provider "aws"
{
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

#Create key pair
resource "aws_key_pair" "zox" {
   key_name   = "zox"
  public_key = "${var.public_key}"
}
#
