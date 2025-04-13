#### DATA ####

data "aws_ec2_transit_gateway" "shared_tgw" {
  id = ""
}

data "aws_ec2_transit_gateway_vpc_attachment" "ingress_attachment" {
  id = ""
}

data "aws_ec2_transit_gateway_vpc_attachment" "security_attachment" {
  id = ""
}

data "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  id = ""
}

data "aws_ec2_transit_gateway_vpc_attachment" "shared_attachment" {
  id = ""
}

data "aws_ec2_transit_gateway_vpc_attachment" "egress_attachment" {
  id = ""
}


#### SHARED ####

resource "aws_ec2_transit_gateway_route_table" "shared_tgw_rt" {
  transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  tags = {
    name = var.shared_tgw_rt_name
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "shared_tgw_association" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_propagation_prod" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_tgw_rt.id
}

#### SECURITY ####

resource "aws_ec2_transit_gateway_route_table" "security_tgw_rt" {
  transit_gateway_id = data.shared_tgw.id
  tags = {
    name = var.security_tgw_rt_name
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "security_tgw_association" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.security_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "security_propagation_prod" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}

#### PROD ####

resource "aws_ec2_transit_gateway_route_table" "production_tgw_rt" {
  transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  tags = {
    name = var.prod_tgw_rt_name
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "prod_tgw_association" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_propagation_shared" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_propagation_ingress" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.ingress_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "prod_prefix_default_route" {
  destination_cidr_block         = var.default_route
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.security_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production_tgw_rt.id
}

#### INGRESS ####

resource "aws_ec2_transit_gateway_route_table" "ingress_tgw_rt" {
  transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  tags = {
    name = var.ingress_tgw_rt_name
  }
}

#resource "aws_ec2_transit_gateway_route" "ingress_prefix_default_route" {
#  destination_cidr_block         = var.default_route
#  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingress_tgw_rt.id
#}

resource "aws_ec2_transit_gateway_route_table_association" "ingress_tgw_association" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.ingress_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingress_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "ingress_propagation_prod" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingress_tgw_rt.id
}

#### EGRESS ####

resource "aws_ec2_transit_gateway_route_table" "egress_tgw_rt" {
  transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  tags = {
    name = var.egress_tgw_rt_name
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "egress_tgw_association" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.egress_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "egress_prefix_aws" {
  destination_cidr_block         = var.pref_aws
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.security_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_tgw_rt.id
}

#resource "aws_ec2_transit_gateway_route_table_propagation" "egress_propagation_security" {
#  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingress_tgw_rt.id
#}