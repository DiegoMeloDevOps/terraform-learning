resource "aws_internet_gateway" "igw" {

  vpc_id = var.vpc_id

  tags = {
    Name = "main_igw"
  }

}

resource "aws_route_table" "public" {

  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "route-public" }
}

resource "aws_route_table_association" "public" {

  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.public.id
}
