resource "aws_route53_zone" "this" {
  name = var.name

  vpc {
    vpc_id = var.vpc
  }
}