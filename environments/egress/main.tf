
############### VPC ###############

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr_block       = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags_private         = var.tags_private
  tags_transit         = var.tags_transit
  availability_zones   = var.availability_zones
  letter_azs           = var.letter_azs
  vpc_name             = var.vpc_name
}

module "igw" {
  source   = "../../modules/igw"
  vpc      = module.vpc.vpc_id
  igw_name = var.igw_name
}

############## DATA ################

data "aws_ec2_transit_gateway" "shared_tgw" {
  id = "tgw-00af4652650ae289c"
}

module "tgw_attachment" {
  source    = "../../modules/tgw-attach"
  vpc       = module.vpc.vpc_id
  subnet_id = module.vpc.transit_subnets_ids
  tgw_id          = data.aws_ec2_transit_gateway.shared_tgw.id
  tgw_attach_name = var.tgw_attach_name
}


############## ROUTE TABLES ################

resource "aws_route_table" "rt_transit" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = var.default_route
    nat_gateway_id = module.nat-gateway-1.nat_gateway_id
  }
  
  route {
    cidr_block = var.default_route
    nat_gateway_id = module.nat-gateway-2.nat_gateway_id
  }

  tags = {
    Name = var.rt_transit_name
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block         = var.cidr_block
    transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  }

  route {
    cidr_block = var.default_route
    gateway_id = module.igw.igw_id
  }

  tags = {
    Name = var.rt_private_name
  }
}

# Route table association

resource "aws_route_table_association" "rt_private_association" {
  count          = length(module.vpc.priv_subnets_ids)
  route_table_id = aws_route_table.rt_private.id
  subnet_id      = module.vpc.priv_subnets_ids[count.index]
}

resource "aws_route_table_association" "rt_transit_association" {
  count          = length(module.vpc.transit_subnets_ids)
  route_table_id = aws_route_table.rt_transit.id
  subnet_id      = module.vpc.transit_subnets_ids[count.index]
}

############## NAT GATEWAY ################

module "nat-gateway-1" {
  source = "../../modules/ngw"
  subnet_id = module.vpc.priv_subnets_ids[0]
  nat_tag = var.nat_tag_1
}

module "nat-gateway-2" {
  source = "../../modules/ngw"
  subnet_id = module.vpc.priv_subnets_ids[1]
  nat_tag = var.nat_tag_2
}