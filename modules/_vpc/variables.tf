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

variable "main_cidr_block" {
  type = list(any)
  description = "List of main subnets CIDR blocks"
  }

variable "secondary_cidr_block" {
  type = list(any)
  description = "List of Secondary subnets CIDR blocks"
  }

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

variable "tag_main_subnet" {
  type = string
}

variable "tag_secondary_subnet" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "main_route_table_id" {
  type = string
}

variable "secondary_route_table_id" {
  type = string
}

