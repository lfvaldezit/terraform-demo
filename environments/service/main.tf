
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

############### DATA ###############

module "tgw" {
  source   = "../../modules/tgw"
  asn      = var.tgw_asn
  tag_name = var.tgw_name
}

## TGW attachment
#
module "tgw_attachment" {
  source    = "../../modules/tgw-attach"
  vpc       = module.vpc.vpc_id
  subnet_id = module.vpc.transit_subnets_ids
  tgw_id    = module.tgw.tgw_id
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
    transit_gateway_id = module.tgw.tgw_id
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

############### RAM ###############

module "tgw_ram" {
  source                    = "../../modules/ram"
  ram_name                  = var.ram_name
  allow_external_principals = var.allow_external_principals
  ram_principals            = var.ram_principals
}

# RAM association

resource "aws_ram_resource_association" "tgw_ram_association" {
  resource_arn       = module.tgw.tgw_arn
  resource_share_arn = module.tgw_ram.ram_arn
}


############### OUTPUTS ################

output "tgw_attachment_id" {
  value = module.tgw_attachment.tgw_attachment_id
}
