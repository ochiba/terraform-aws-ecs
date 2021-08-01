resource "aws_subnet" "public" {
  count = length(var.subnets.public)

  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}${var.subnets.public[count.index].az}"
  cidr_block        = var.subnets.public[count.index].cidr

  tags = { Name = "${var.stack_prefix}-sbn-pub-${var.subnets.public[count.index].az}" }
}

resource "aws_subnet" "private" {
  count = length(var.subnets.private)

  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}${var.subnets.private[count.index].az}"
  cidr_block        = var.subnets.private[count.index].cidr

  tags = { Name = "${var.stack_prefix}-sbn-prv-${var.subnets.private[count.index].az}" }
}