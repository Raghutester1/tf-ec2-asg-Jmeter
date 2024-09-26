resource "aws_vpc" "RAG_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "RAG_vpc"
  }
}

resource "aws_internet_gateway" "RAG_igw" {
  vpc_id = aws_vpc.RAG_vpc.id

  tags = {
    Name = "RAG_igw"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.RAG_vpc.id
  cidr_block        = var.public_subnet_cidr1
  availability_zone = var.availibilty_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.RAG_vpc.id
  cidr_block        = var.public_subnet_cidr2
  availability_zone = var.availibilty_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.RAG_vpc.id
  cidr_block        = var.private_subnet_cidr1
  availability_zone = var.availibilty_zone_1

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.RAG_vpc.id
  cidr_block        = var.private_subnet_cidr2
  availability_zone = var.availibilty_zone_2
  tags = {
    Name = "private_subnet2"
  }
}

resource "aws_nat_gateway" "RAG_nat_gw" {
  allocation_id = aws_eip.RAG_nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.RAG_igw]
  tags = {
    Name = "RAG_nat_gw"
  }
}

resource "aws_eip" "RAG_nat_eip" {
  depends_on    = [aws_internet_gateway.RAG_igw]
  domain = "vpc"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.RAG_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.RAG_igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.RAG_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.RAG_nat_gw.id
  }
}

resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
