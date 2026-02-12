locals {
  common_tags = {
    Project     = "django"
    Environment = "Dev"
  }
}

resource "aws_vpc" "django_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    local.common_tags,
    { Name = "django-vpc" }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "django_public_subnet_a" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = var.public_subnet_cidr_block_a
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    { Name = "django-public-subnet-a" }
  )
}

resource "aws_subnet" "django_public_subnet_b" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = var.public_subnet_cidr_block_b
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    { Name = "django-public-subnet-b" }
  )
}

resource "aws_subnet" "django_private_subnet_a" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = var.private_subnet_cidr_block_a
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    { Name = "django-private-subnet-a" }
  )
}

resource "aws_subnet" "django_private_subnet_b" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = var.private_subnet_cidr_block_b
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    { Name = "django-private-subnet-b" }
  )
}

resource "aws_internet_gateway" "django_igw" {
  vpc_id = aws_vpc.django_vpc.id

  tags = merge(
    local.common_tags,
    { Name = "django-igw" }
  )
}

resource "aws_eip" "django_nat_eip" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    { Name = "django-nat-eip" }
  )
}

resource "aws_nat_gateway" "django_nat_gw" {
  allocation_id = aws_eip.django_nat_eip.id
  subnet_id     = aws_subnet.django_public_subnet_a.id

  tags = merge(
    local.common_tags,
    { Name = "django-nat-gw" }
  )

  depends_on = [aws_internet_gateway.django_igw]
}

resource "aws_route_table" "django_public_route_table" {
  vpc_id = aws_vpc.django_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.django_igw.id
  }

  tags = merge(
    local.common_tags,
    { Name = "django-public-rt" }
  )
}

resource "aws_route_table_association" "django_public_route_table_association" {
  subnet_id      = aws_subnet.django_public_subnet_a.id
  route_table_id = aws_route_table.django_public_route_table.id
}

resource "aws_route_table_association" "django_public_route_table_association_b" {
  subnet_id      = aws_subnet.django_public_subnet_b.id
  route_table_id = aws_route_table.django_public_route_table.id
}

resource "aws_route_table" "django_private_route_table" {
  vpc_id = aws_vpc.django_vpc.id

  tags = merge(
    local.common_tags,
    { Name = "django-private-rt" }
  )
}

resource "aws_route_table_association" "django_private_route_table_association" {
  subnet_id      = aws_subnet.django_private_subnet_a.id
  route_table_id = aws_route_table.django_private_route_table.id
}

resource "aws_route_table_association" "django_public_route_table_association_private_route_table_association_b" {
  subnet_id      = aws_subnet.django_private_subnet_b.id
  route_table_id = aws_route_table.django_private_route_table.id
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.django_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.django_nat_gw.id
}
