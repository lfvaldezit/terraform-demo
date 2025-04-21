resource "aws_route53_resolver_rule" "this" {
  domain_name          = var.domain_name
  name                 = var.name
  rule_type            = "FORWARD"
  resolver_endpoint_id = var.resolver_endpoint_id

  target_ip {
    ip = var.target_ip
  }
}

resource "aws_route53_resolver_rule_association" "example" {
  resolver_rule_id = aws_route53_resolver_rule.this.id
  vpc_id           = var.vpc_id
}