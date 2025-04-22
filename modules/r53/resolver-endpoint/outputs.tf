output "resolver_endpoint_id" {
  value = aws_route53_resolver_endpoint.this.id
}

output "ip_address" {
  value = aws_route53_resolver_endpoint.this.ip_address
}