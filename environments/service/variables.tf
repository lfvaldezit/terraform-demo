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

variable "sn_tag_private" {
  type = string
}

variable "sn_tag_transit" {
  type = string
}

variable "letter_azs" {
  type = list(string)
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "private_cidr_block" {
  type = list(any)
}

variable "transit_cidr_block" {
  type = list(any)
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

variable "fwd1_ram_name" {
  type = string
}

variable "fwd2_ram_name" {
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

# R53 RESOLVER

variable "inbound_name" {
  type = string
}

variable "inbound_direction" {
  type = string
}

variable "inbound_ip_a" {
  type = string
}

variable "inbound_ip_b" {
  type = string
}

variable "outbound_name" {
  type = string
}

variable "outbound_direction" {
  type = string
}

variable "outbound_ip_a" {
  type = string
}

variable "outbound_ip_b" {
  type = string
}

variable "corp_rule_name" {
  type = string
}

variable "corp_domain_name" {
  type = string
}

variable "corp_target_ip_a" {
  type = string
}

variable "corp_target_ip_b" {
  type = string
}

variable "cloud_rule_name" {
  type = string
}

variable "cloud_domain_name" {
  type = string
}

variable "cloud_target_ip_a" {
  type = string
}

variable "cloud_target_ip_b" {
  type = string
}

variable "sg_name" {
  type = string
}