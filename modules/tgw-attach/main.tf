resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment" {
  vpc_id             = var.vpc
  transit_gateway_id = var.tgw_id
  subnet_ids         = var.subnet_id
  tags = {
    Name = "${var.tgw_attach_name}"
   }
}

