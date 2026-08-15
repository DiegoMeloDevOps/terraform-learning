resource "aws_secretsmanager_secret" "rds_secret" {
  # chamando uma variavel para mudar o nome do segredo por ambiente
  name = var.rds_name
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id


  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}