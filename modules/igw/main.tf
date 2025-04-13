resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc

  tags = {
    Name = var.igw_name
  }
}

#resource "aws_internet_gateway_attachment" "igw_attachment" {
#  internet_gateway_id = aws_internet_gateway.this.id
#  vpc_id              = var.vpc
#}