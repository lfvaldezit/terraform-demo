resource "aws_ec2_transit_gateway" "tgw" {
  amazon_side_asn                 = var.asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = {
    Name = var.tag_name
  }
}

