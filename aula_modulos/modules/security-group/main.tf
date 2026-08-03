resource "aws_security_group" "web" {

  name        = "web-security-group"
  description = "SG para servidor WEB"
  # o vpc id já está exposto no modulo vpc no output dele
  vpc_id = var.vpc_id


  # Ingress oq eu to permitindo que entre na rede
  ingress {
    description = "acesso HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "acesso via HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # oque eu to permitindo que saia da rede
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }

}