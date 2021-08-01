# Public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.stack_prefix}-rtb-pub" }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [
    aws_subnet.public,
    aws_route_table.public
  ]
}

# Private subnet
resource "aws_route_table" "private" {
  count = length(var.subnets.private)

  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.stack_prefix}-rtb-prv-${var.subnets.private[count.index].az}" }
}

resource "aws_route" "private" {
  count = length(var.subnets.private)

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
}

resource "aws_route_table_association" "private" {
  count = length(var.subnets.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

  depends_on = [
    aws_subnet.private,
    aws_route_table.private
  ]
}