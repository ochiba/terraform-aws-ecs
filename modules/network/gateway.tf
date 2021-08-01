# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.stack_prefix}-igw" }
}

# NAT Gateway
resource "aws_eip" "ngw" {
  count = length(var.subnets.public)

  vpc = true

  tags = { Name = "${var.stack_prefix}-eip-ngw-${var.subnets.public[count.index].az}" }
}

resource "aws_nat_gateway" "main" {
  count = length(var.subnets.public)

  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.ngw[count.index].id

  tags = { Name = "${var.stack_prefix}-ngw-${var.subnets.public[count.index].az}" }
}