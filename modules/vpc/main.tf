### VPC ###

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
    tags = {
    name = var.vpc_name
  }
}

### SUBNETS ###

resource "aws_subnet" "sn_transit" {

  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 2, count.index)
  availability_zone = element(var.availability_zones, count.index)
  

  tags = {
    Name = "${var.tags_transit}${upper(var.letter_azs[count.index])}"
  }
}

resource "aws_subnet" "sn_private" {

  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 2, count.index + 2)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tags_private}${upper(var.letter_azs[count.index])}"
  }
}
