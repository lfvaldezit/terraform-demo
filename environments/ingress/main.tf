
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
  #tgw_id          = data.aws_ssm_parameter.shared_tgw_id.value
  tgw_id          = data.aws_ec2_transit_gateway.shared_tgw.id
  tgw_attach_name = var.tgw_attach_name
}


############## ROUTE TABLES ################

resource "aws_route_table" "rt_transit" {
  vpc_id = module.vpc.vpc_id

  #route {
  #  cidr_block = var.default_route
  #  gateway_id = module.igw.igw_id
  #}


  tags = {
    Name = var.rt_transit_name
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block         = var.cidr_prod
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

############## SECURITY GROUP ################

module "alb_security_group" {
  source = "../../modules/security-group"
  name   = "${var.lb_name}-sg"
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = [22, 80, 443]
  ingress_cidr_to_port   = [22, 80, 443]
  ingress_cidr_block     = [var.default_route, var.default_route]
  ingress_cidr_protocol  = ["tcp", "tcp", "tcp"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "true"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = [var.default_route]

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []

}

############## ALB ################

module "alb" {
  source = "../../modules/alb"
  lb_name = var.lb_name
  internal = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups = [module.alb_security_group.security_group_ids]
  subnets = [ for subnet in module.vpc.priv_subnets_ids : subnet ]
  vpc_id = module.vpc.vpc_id
  port = var.port
  protocol = var.protocol
  target_type = var.target_type
  health_check_path = var.health_check_path
  health_protocol = var.protocol
}

resource "aws_lb_target_group_attachment" "tg-attachment" {
  target_group_arn = module.alb.target_group_arn
  target_id        = var.target_id
  port             = var.port
  availability_zone = "all"
}

############## CLOUD FRONT ################ 

module "cloudfront" {
  source = "../../modules/cloud-front"
  domain_name = module.alb.dns_name
  origin_id = var.origin_id
  http_port = var.http_port
  https_port = var.https_port
  enabled = var.enabled
  #default_root_object = var.default_root_object
}