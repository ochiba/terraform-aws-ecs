resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count = length(var.subnets_public)

  vpc_id            = aws_vpc.main.id
  availability_zone = values(var.subnets_public)[count.index].availability_zone
  cidr_block        = values(var.subnets_public)[count.index].cidr

  tags = {
    Name = "${var.name}-sn-${keys(var.subnets_public)[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-rt-public"
  }
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
}

# Private Subnet
resource "aws_subnet" "private" {
  count = length(var.subnets_private)

  vpc_id            = aws_vpc.main.id
  availability_zone = values(var.subnets_private)[count.index].availability_zone
  cidr_block        = values(var.subnets_private)[count.index].cidr

  tags = {
    Name = "${var.name}-sn-${keys(var.subnets_private)[count.index]}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-rt-private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}