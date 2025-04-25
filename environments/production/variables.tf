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

variable "cidr_ingress" {
  type = string
}

variable "default_route" {
  type = string
}

variable "tags_tgw_attachment" {
  type = string
}

variable "profile" {
  type = string
}

variable "ram_tgw_attach_id_name" {
  type = string
}

variable "allow_external_principals" {
  type = bool
}

variable "ram_principals" {
  type = string
}

variable "ssm_path_tgw_attach_id" {
  type = string
}

variable "shared_tgw_arn" {
  type = string
}


###### Security Group ######

variable "sg_name" {
  type = string
}

###### EC2 ######

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

#### ALB ####

variable "lb_name" {
  type = string
}

variable "internal" {
  type = bool
}

variable "alb_sg_name" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "tg_name" {
  type = string
}

variable "port" {
  type = string
}

variable "protocol" {
  type = string
}

variable "health_protocol" {
  type = string
}


variable "target_type" {
  type = string
}

variable "associate_public_ip_address" {
  type = bool
}

variable "health_check_path" {
  type = string
}

### TGW ###

variable "shared_tgw" {
  description = "Transit Gateway Id:"
  type        = string
}

### HOSTED ZONE ###

variable "domain_name" {
  type = string
}

variable "service_vpc_id" {
  description = "VPC ID to be associated with PHZ:"
  type        = string
}