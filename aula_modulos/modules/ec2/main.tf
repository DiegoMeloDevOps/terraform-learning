resource "aws_instance" "servers" {

  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  #adicionado após revisão do checkov
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true

  root_block_device {
    encrypted = true
  }

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = var.instance_name



  }

}

