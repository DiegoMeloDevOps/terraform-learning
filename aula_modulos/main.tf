
module "vpc" {
  source = "./modules/vpc"

  cidr_block         = "10.0.0.0/16"
  name_network       = "minha-vpc"
  cidr_block_public  = "10.0.1.0/24"
  network_public     = "subnet-publica"
  cidr_block_private = "10.0.2.0/24"
  network_private    = "subnet-privada"
}


locals {
  servers = {
    app = "t2.small"
    api = "t2.micro"
    db  = "t2.medium"
  }
}

module "ec2" {
  source   = "./modules/ec2"
  for_each = local.servers

  ami           = "ami-12345678"
  instance_type = each.value
  instance_name = each.key

  subnet_id = (
    each.key == "app" ? module.vpc.public_subnet_id : module.vpc.private_subnet_id
  )
}