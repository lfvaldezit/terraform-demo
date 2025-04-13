output "target_group_arn" {
    value = aws_lb_target_group.this.arn
}

output "dns_name" {
    value = aws_alb.this.dns_name
}