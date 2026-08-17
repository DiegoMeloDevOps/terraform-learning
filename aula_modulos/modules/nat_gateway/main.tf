resource "aws_eip" "ip_nat" {
  domain = "vpc"

  tags = {
    Name = "ip_nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.ip_nat.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "private_instances" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-instances-route-table"
  }
}

resource "aws_route_table_association" "private_nat" {
  subnet_id      = var.private_subnet_id
  route_table_id = aws_route_table.private_instances.id
}