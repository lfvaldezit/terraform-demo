resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "this" {
  for_each          = { for subnet in local.subnet_definitions : subnet.name => subnet }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block  
  availability_zone = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}