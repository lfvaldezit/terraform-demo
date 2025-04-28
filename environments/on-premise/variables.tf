############### VPC ###############

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "instance_tenancy" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "enable_dns_support" {
  type = bool
}

variable "letter_azs" {
  type = list(string)
}

variable "public_cidr_block" {
  type = list(any)
}

variable "sn_tag_public" {
  type = string
}

variable "private_cidr_block" {
  type = list(any)
}

variable "sn_tag_private" {
  type = string
}
############### IGW ###############

variable "igw_name" {
  type = string
}

############### ROUTE TABLES ###############

variable "rt_public_name" {
  type = string
}

variable "default_route" {
  type = string
}

variable "rt_private_name" {
  type = string
}

############### ENI ###############

variable "public_device_index" {
  type = string
}

variable "private_device_index" {
  type = string
}

variable "source_dest_check" {
  type = bool
}

variable "domain" {
  type = string
}

variable "privates_ips" {
  type = list(string)
}

############### SECURITY GROUP ###############

variable "router_sg_name" {
  type = string
}

variable "dns_sg_name" {
  type = string
}

variable "aws_prefix" {
  type = string
}

############### EC2 ###############

variable "dns_ami" {
  type = string
}

variable "dns_instance_type" {
  type = string
}
