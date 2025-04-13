
############### VPC ###############

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr_block       = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags_private         = var.sn_tags_private
  tags_transit         = var.sn_tags_transit
  availability_zones   = var.availability_zones
  letter_azs           = var.letter_azs
  vpc_name             = var.vpc_name
}

############### TGW ###############

data "aws_ec2_transit_gateway" "shared_tgw" {
  id = var.shared_tgw
}

module "tgw_attachment" {
  source    = "../../modules/tgw-attach"
  vpc       = module.vpc.vpc_id
  subnet_id = module.vpc.transit_subnets_ids
  tgw_id          = data.aws_ec2_transit_gateway.shared_tgw.id
  tgw_attach_name = var.tgw_attach_name
}

############### ROUTE TABLES ###############

resource "aws_route_table" "rt_transit" {
  vpc_id = module.vpc.vpc_id

  route = []

  tags = {
    Name = var.rt_transit_name
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = module.vpc.vpc_id
  
  route {
    cidr_block         = var.default_route
    transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  }

  tags = {
    Name = var.rt_private_name
  }
}

# Route table association

resource "aws_route_table_association" "rt-private-association" {
  count          = length(module.vpc.priv_subnets_ids)
  route_table_id = aws_route_table.rt_private.id
  subnet_id      = module.vpc.priv_subnets_ids[count.index]
}

resource "aws_route_table_association" "rt-transit-association" {
  count          = length(module.vpc.transit_subnets_ids)
  route_table_id = aws_route_table.rt_transit.id
  subnet_id      = module.vpc.transit_subnets_ids[count.index]
}
