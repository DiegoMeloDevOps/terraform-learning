resource "aws_secretmanager_secret" "rds_secret" {
  # chamando uma variavel para mudar o nome do segredo por ambiente
  name = var.rds_name
}

resource "aws_secretmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretmanager_secret.rds_secret.identifier


  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}