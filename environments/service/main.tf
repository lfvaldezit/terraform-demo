
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
  source          = "../../modules/tgw-attach"
  vpc             = module.vpc.vpc_id
  subnet_id       = module.vpc.transit_subnets_ids
  tgw_id          = module.tgw.tgw_id
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

############### R53 RESOLVER ENDPOINTS ################

module "security_group" {
  source = "../../modules/security-group"
  name   = var.sg_name
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = [53, 53]
  ingress_cidr_to_port   = [53, 53]
  
  ingress_cidr_block     = [var.default_route, var.default_route]
  ingress_cidr_protocol  = ["tcp", "udp"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "false"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = []

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []

}

module "inbound" {
  source             = "../../modules/r53/resolver-endpoint"
  name               = var.inbound_name
  direction          = var.inbound_direction
  security_group_ids = module.security_group.security_group_ids

  subnet_id_a = module.vpc.priv_subnets_ids[0]
  subnet_id_b = module.vpc.priv_subnets_ids[1]

}

module "outbound" {
  source             = "../../modules/r53/resolver-endpoint"
  name               = var.outbound_name
  direction          = var.outbound_direction
  security_group_ids = module.security_group.security_group_ids

  subnet_id_a = module.vpc.priv_subnets_ids[0]
  subnet_id_b = module.vpc.priv_subnets_ids[1]

}

module "fwd-corp_lfvaldezit" {
  source               = "../../modules/r53/resolver-rule"
  domain_name          = var.corp_domain_name
  name                 = var.corp_rule_name
  resolver_endpoint_id = module.outbound.resolver_endpoint_id
  target_ip_a        = var.corp_target_ip_a
  target_ip_b        = var.corp_target_ip_b
  vpc_id = module.vpc.vpc_id
}

module "fwd-cloud_lfvaldezit" {
  source               = "../../modules/r53/resolver-rule"
  domain_name          = var.cloud_domain_name
  name                 = var.cloud_rule_name
  resolver_endpoint_id = module.outbound.resolver_endpoint_id
  target_ip_a        = var.cloud_target_ip_a
  target_ip_b        = var.cloud_target_ip_b
  vpc_id = module.vpc.vpc_id
}

module "ram_fwd_corp" {
  source = "../../modules/ram"
  ram_name = var.fwd1_ram_name
  ram_principals = var.ram_principals
  allow_external_principals = var.allow_external_principals
}

resource "aws_ram_resource_association" "fwd_corp_ram_association" {
  resource_arn       = module.fwd-corp_lfvaldezit.resolver_arn
  resource_share_arn = module.ram_fwd_corp.ram_arn
}

#module "ram_fwd_cloud" {
#  source = "../../modules/ram"
#  ram_name = var.fwd1_ram_name
#  ram_principals = var.ram_principals
#  allow_external_principals = var.allow_external_principals
#}
#
#resource "aws_ram_resource_association" "fwd_cloud_ram_association" {
#  resource_arn       = module.fwd-cloud_lfvaldezit.resolver_arn
#  resource_share_arn = module.ram_fwd_cloud.ram_arn
#}


############### OUTPUTS ################

output "tgw_id" {
  value = module.tgw.tgw_id
}

output "tgw_attachment_id" {
  value = module.tgw_attachment.tgw_attachment_id
}


