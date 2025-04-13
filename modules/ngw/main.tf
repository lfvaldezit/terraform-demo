
resource "aws_eip" "this" {
  domain = true
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this
  subnet_id     = var.subnet_id

  tags = {
    Name = var.nat_tag
  }
}