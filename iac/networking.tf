resource "aws_vpc" "spectaclesxr" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "spectaclesxr"
  }
}

resource "aws_internet_gateway" "spectaclesxr" {
  vpc_id = aws_vpc.spectaclesxr.id
  tags = {
    Name = "spectaclesxr"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.spectaclesxr.id
  cidr_block        = cidrsubnet(aws_vpc.spectaclesxr.cidr_block, 8, count.index)
  availability_zone = element(["us-west-1a", "us-west-1b"], count.index)

  tags = {
    Name = "spectaclesxr-public-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.spectaclesxr.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.spectaclesxr.id
  }

  tags = {
    Name = "spectaclesxr-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
