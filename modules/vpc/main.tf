resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "private-subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_eip" "ngw" {
  domain   = "vpc"
  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id = var.account_no
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true
  tags = {
    Name = "peering-from-default-vpc-to-${var.env}-vpc"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "private"
  }
}

resource "aws_route" "default-route-table" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route_table_association" "public" {
  count      = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count      = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}