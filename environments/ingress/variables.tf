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

variable "tags_tgw_attachment" {
  type = string
}

#variable "shared_tgw_id" {
#  description = "Transit Gateway (Shared environment) ID: "
#  type = string
#}

#### ALB ####

variable "lb_name" {
  type = string
}

variable "internal" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "port" {
  type = string
}

variable "protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "target_id" {
  type = string
}

### CLOUD FRONT ###

variable "origin_id" {
  type = string
}

variable "http_port" {
  type = string
}

variable "https_port" {
  type = string
}

variable "enabled" {
  type = bool
}

#variable "default_root_object" {
#  type = string
#}