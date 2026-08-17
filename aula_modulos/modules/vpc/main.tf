resource "aws_vpc" "main" {

  cidr_block = var.cidr_block

  tags = {
    Name = var.name_network
  }

}

resource "aws_subnet" "public" {

  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block_public

  tags = {
    Name = var.network_public
  }

}

resource "aws_subnet" "private" {

  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block_private

  tags = {
    Name = var.network_private
  }

}

# está é a sub rede para o banco rds 
resource "aws_subnet" "rds_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_rds_a
  # criando 2 zonas de disponibilidade para a sub-rede do banco RDS
  availability_zone = var.availability_zone_a


  tags = {
    Name = "rds-private-a"
  }

}

resource "aws_subnet" "rds_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_rds_b
  availability_zone = var.availability_zone_b


  tags = {
    Name = "rds-private-b"
  }
}

# adicionado após o checkov
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress = []

  egress = []

  tags = {
    Name = "${var.name_network}-default-sg"
  }
}