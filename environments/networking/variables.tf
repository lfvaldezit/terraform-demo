variable "tgw_name" {
  type = string
}

variable "tgw_asn" {
  type = string
}

variable "tgw_ram_name" {
  type = string
}

variable "allow_external_principals" {
  type = bool
}

variable "ram_principals" {
  type = string
}

variable "ram_tgw_id_name" {
  type = string
}

variable "shared_tgw_rt_name" {
  type = string
}

variable "security_tgw_rt_name" {
  type = string
}

variable "prod_tgw_rt_name" {
  type = string
}

variable "ingress_tgw_rt_name" {
  type = string
}

variable "egress_tgw_rt_name" {
  type = string
}

variable "default_route" {
  type = string
}

variable "pref_on_premise" {
  type = string
}

variable "pref_aws" {
  type = string
}

variable "pref_ingress" {
  type = string
}
### ###

variable "service_vpc_id" {
  description = "VPC ID to be associated with PHZ (corp.lfvaldezit.click):"
  type = string
}

variable "host_id" {
  description = "Host ID (corp.lfvaldezit.click):"
  type = string
}