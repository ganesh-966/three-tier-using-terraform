variable "region" {
  default = "ap-southeast-1"
}

variable "az1" {
  default = "ap-southeast-1a"
}

variable "az2" {
  default = "ap-southeast-1b"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_cidr" {
  default = "10.0.0.0/20"
}

variable "private_cidr" {
  default = "10.0.16.0/20"
}

variable "private_cidr_b" {
  default = "10.0.32.0/20"
}



variable "project_name" {
  default = "three-tier"
}

variable "igw_cidr" {
  default = "0.0.0.0/0"
}

variable "ami" {
  default = "ami-05f071c65e32875a8"
}

variable "instance-type" {
  default = "t2.micro"
}

variable "key" {
  default = "singapore"
}