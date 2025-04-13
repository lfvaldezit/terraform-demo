variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "instance_tenancy" {
  type = string
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether to enable DNS support or not"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable DNS hostnames or not"
}

variable "tags_private" {
  type = string
}

variable "tags_transit" {
  type = string
}

variable "letter_azs" {
  type = list(string)
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}


variable "tgw_attach_name" {
  type = string
}

variable "vpc_name" {
  type = string
}


variable "rt_transit_name" {
  type = string
}

variable "rt_private_name" {
  type = string
}

variable "igw_name" {
  type = string
}

variable "default_route" {
  type = string
}

variable "cidr_prod" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "tags_tgw_attachment" {
  type = string
}

### NAT GATEWAY ###

variable "nat_tag_1" {
  type = string
}

variable "nat_tag_2" {
  type = string
}