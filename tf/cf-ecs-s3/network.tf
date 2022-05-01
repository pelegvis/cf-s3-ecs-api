# vpc
resource "aws_vpc" "api_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo_api_vpc"
  }
}

# subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = "10.0.1.0/25"
  availability_zone = "${var.region}a"
  tags = {
    "Name" = "public | ${var.region}a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = "10.0.1.128/25"
  availability_zone = "${var.region}b"
  tags = {
    "Name" = "public | ${var.region}b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "${var.region}a"
   tags = {
    "Name" = "private | ${var.region}a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = "10.0.2.128/25"
  availability_zone = "${var.region}b"
  tags = {
    "Name" = "private | ${var.region}b"
  }
}

# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.api_vpc.id
  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.api_vpc.id
  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_a_subnet" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a_subnet" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

# internet and NAT gateways
resource "aws_eip" "nat" {
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.api_vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

#security groups
resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.api_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "HTTPS traffic"
  vpc_id      = aws_vpc.api_vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.api_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_api" {
  name        = "ingress-api"
  description = "Allow ingress to API"
  vpc_id      = aws_vpc.api_vpc.id
  ingress {
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

