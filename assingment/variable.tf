variable "pname"{}

variable "access_key"{}
variable "secret_key"{}
variable "region"{}

variable "count" {
  default = "1"

}
variable "key_name"{}
variable "instance_type" {
  default = "t2.micro"
}

variable "user_data"{}

variable "public_key" {}

variable "cidr" {
  default = "0.0.0.0/0"
}
