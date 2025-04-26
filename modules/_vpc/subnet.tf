
resource "aws_subnet" "main" {

  count             = length(var.main_cidr_block)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.main_cidr_block, count.index)
  availability_zone = element(var.availability_zones, count.index)
  

  tags = {
    Name = "${var.tag_main_subnet}${upper(var.letter_azs[count.index])}"
  }
}

resource "aws_route_table_association" "main" {
  count          = length(aws_subnet.main)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = var.main_route_table_id
}

resource "aws_subnet" "secondary" {

  count             = length(var.secondary_cidr_block)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.secondary_cidr_block, count.index)
  availability_zone = element(var.availability_zones, count.index)
  

  tags = {
    Name = "${var.tag_secondary_subnet}${upper(var.letter_azs[count.index])}"
  }
}

resource "aws_route_table_association" "secondary" {
  count          = length(aws_subnet.secondary)
  subnet_id      = aws_subnet.secondary[count.index].id
  route_table_id = var.secondary_route_table_id
}

