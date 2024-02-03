provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-vpc"
    }
  )
}

# Add provisioning of the public subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}

# Add provisioning of the private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index}"
      Tier = "Private"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-igw"
    }
  )
}

# Route table for public subnets
resource "aws_route_table" "public_route_table" {
  count  = length(aws_subnet.public_subnet)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-route-public-route_table-${count.index}"
  }
}

# custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet)
  route_table_id = aws_route_table.public_route_table[count.index].id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Create NAT GW for public subnet
resource "aws_nat_gateway" "nat-gw" {
  count         = 1
  allocation_id = aws_eip.nat-eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.prefix}-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create elastic IP for NAT GW
resource "aws_eip" "nat-eip" {
  count  = 1
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-natgw"
  }
}

resource "aws_route_table" "private_route_table" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-route-private-route_table-${count.index}",
    Tier = "Private"
  }
}

# Add route to NAT GW if we created private subnets
resource "aws_route" "private_route" {
  count                  = length(aws_subnet.private_subnet)
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gw[0].id
}

# Associate private subnets with the custom route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
