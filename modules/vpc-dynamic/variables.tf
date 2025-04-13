variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Prefix for all resource names"
}

variable "subnets_per_az" {
  type        = number
  description = "Number of subnets to create per AZ"
  default     = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs              = data.aws_availability_zones.available.names
  subnet_count     = length(local.azs) * var.subnets_per_az
  subnet_prefixes  = [for i in range(local.subnet_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  subnet_definitions = flatten([
    for az_index, az in local.azs : [
      for subnet_index in range(var.subnets_per_az) : {
        name      = "${var.name}-az${az_index}-subnet${subnet_index}"
        az        = az
        cidr_block = local.subnet_prefixes[az_index * var.subnets_per_az + subnet_index]
      }
    ]
  ])
}
