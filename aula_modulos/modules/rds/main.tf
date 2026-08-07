resource "aws_db_instance" "mysql" {

  identifier        = var.identifier_db
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  # como é um modulo eu quero que seje prenchido no main de acordo com a necessidade de cada ambiente
  engine         = var.engine_db
  engine_version = var.engine_version_db
  instance_class = var.instance_type

  # utilizar um modulo secret manager para gerenciar esse segredo
  db_name  = var.db_name
  username = var.username
  password = var.password

  # comando para criar um backup do banco antes de aplicar o destroy
  skip_final_snapshot = false
  # quero separar o nome para cada snapshot de acordo com o seu ambiente
  final_snapshot_identifier = var.name_snapshot_final
  # não quero deixar acessivel a internet
  publicly_accessible = false

  vpc_security_group_ids = [
    var.vpc_security_group_ids
  ]

}