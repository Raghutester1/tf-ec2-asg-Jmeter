variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr2" {
  default = "10.0.2.0/24"
}

variable "private_subnet_cidr1" {
  default = "10.0.3.0/24"
}

variable "private_subnet_cidr2" {
  default = "10.0.4.0/24"
}

variable "region" {
  default = "us-east-2"
}

variable "availibilty_zone_1" {
 default = "us-east-2a"
}

variable "availibilty_zone_2" {
   default = "us-east-2b"

}

# variable "multi_az" {
#   default     = false
#   description = "Muti-az allowed?"
# }

variable "instance_type" {
  default = "t2.micro"
}

variable "desired_capacity" {
  default = 2
}

variable "max_size" {
  default = 5
}

variable "min_size" {
  default = 2
}
