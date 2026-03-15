variable "ami" {}
variable "key_name" {}
variable "instance_name" {}
variable "sg_name" {}

variable "ingress_ports" {
  type = list(number)
}