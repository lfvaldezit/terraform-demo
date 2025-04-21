
resource "aws_route53_resolver_endpoint" "this" {
  name = var.name
  direction = var.direction

  security_group_ids = [var.security_group_ids]
  
  ip_address {
    subnet_id = var.subnet_id_a
  }

  ip_address {
    subnet_id = var.subnet_id_b
  }

}