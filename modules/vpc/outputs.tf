output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "priv_subnets_ids" {
  value = aws_subnet.sn_private[*].id
}

output "transit_subnets_ids" {
  value = aws_subnet.sn_transit[*].id
}
