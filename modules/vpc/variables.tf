# VPC Variables

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "Set instance-tenancy"
}

# Subnet Variables

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether to enable DNS support or not"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable DNS hostnames or not"
}

variable "letter_azs" {
  type = list(string)
}

variable "tags_private" {
  type = string
}

variable "tags_transit" {
  type = string
}

variable "vpc_name" {
  type = string
}

