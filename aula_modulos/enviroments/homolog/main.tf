
provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}



module "vpc" {
  source = "../../modules/vpc"

  cidr_block         = "10.10.0.0/16"
  cidr_block_public  = "10.20.1.0/24"
  cidr_block_private = "10.20.10.0/24"

  cidr_rds_a = "10.20.20.0/24"
  cidr_rds_b = "10.20.21.0/24"

  avaibility_zone_a = "us-east-1a"
  avaibility_zone_b = "us-east-1b"


  name_network    = "homog-vpc"
  network_private = "homog-privada"
  network_public  = "homog-publica"

}


module "security_group" {

  source = "../../modules/security-group"

  vpc_id = module.vpc.vpc_id

}

module "internet_gateway" {
  source = "../../modules/igw"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
}

module "nat_gateway" {
  source            = "../../modules/nat_gateway"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id

  depends_on = [module.internet_gateway]
}

locals {
  servers = {
    app = "t2.small"
    api = "t2.micro"
    db  = "t2.medium"
  }
}

module "ec2" {
  source   = "../../modules/ec2"
  for_each = local.servers

  ami                  = data.aws_ami.ubuntu.id
  instance_type        = each.value
  instance_name        = each.key
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  subnet_id = (
    each.key == "app" ? module.vpc.public_subnet_id : module.vpc.private_subnet_id
  )

  security_group_id = module.security_group.security_group_id

}


module "secrets_manager" {
  source = "../../modules/secrets_manager"

  db_username = var.db_username
  db_password = var.db_password
  rds_name    = "homog-rds"

}

module "rds" {
  source                 = "../../modules/rds"
  identifier_db          = "homog-db"
  allocated_storage      = 30
  engine_db              = "mysql"
  engine_version_db      = "8.0.1"
  db_name                = "homogdb"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = module.security_group.security_group_id
  instance_type          = "db.t3.micro"
  name_snapshot_final    = "backup-homolog-db"
  rds_security_group_id  = module.security_group.rds_security_group_id
  rds_subnet_ids         = module.vpc.rds_subnet_ids
  multi_az               = false
}


