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
    description = "Permitir saida para a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }

}
# criando o securitu group exclusivo para o banco de dados
resource "aws_security_group" "rds" {
  name        = "rds-security-grop"
  description = "Permite somente a comunicação entre o rds e a aplicação"
  vpc_id      = var.vpc_id


  ingress {
    description     = "MySQL vindo direto da aplicação"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Permitir saida para a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-security-group" }
}