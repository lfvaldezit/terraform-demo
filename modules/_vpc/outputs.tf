output "vpc_id" {
  value = aws_vpc.this.id
}

output "main_subnet_id" {
  value = aws_subnet.main[*].id
}

output "secondary_subnet_id" {
  value = aws_subnet.secondary[*].id
}

