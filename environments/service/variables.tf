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

variable "sn_tags_private" {
  type = string
}

variable "sn_tags_transit" {
  type = string
}

variable "letter_azs" {
  type = list(string)
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "tgw_asn" {
  type = string
}

variable "tgw_name" {
  type = string
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

variable "ram_name" {
  type = string
}

variable "ram_tgw_id" {
  type = string
}

variable "allow_external_principals" {
  type = bool
}

variable "ram_principals" {
  type = string
}

variable "default_route" {
  type = string
}
