resource "aws_vpc" "main"{

    cidr_block = var.cidr_block

    tags = {
        Name = var.name_network
    }

}

resource "aws_subnet" "public"{

    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_block_public

    tags = {
        Name = var.network_public
    }

}

resource "aws_subnet" "private"{
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_block_private

    tags = {
        Name = var.network_private
    }

}