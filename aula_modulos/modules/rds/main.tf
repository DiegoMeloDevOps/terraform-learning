resource "aws_db_subnet_group" "this" {
  # var.identifier_db é para nomear o nome por ambiente
  name       = "${var.identifier_db}-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = { name = "${var.identifier_db}-subnet-group" }
}
resource "aws_db_instance" "mysql" {

  identifier        = var.identifier_db
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  # como é um modulo eu quero que seje prenchido no main de acordo com a necessidade de cada ambiente
  engine         = var.engine_db
  engine_version = var.engine_version_db
  instance_class = var.instance_type

  # aqui foi adicionado após a revisão do checkov
  storage_encrypted            = true
  auto_minor_version_upgrade   = true
  monitoring_interval          = 60
  performance_insights_enabled = true
  # para impedir que seja destruido o rds ao rodarem um terraform destroy, passarei como variavel para o ambiente dev/homo ser false pelo o custo
  deletion_protection          = var.deletion_protection

  # se ele ira iter replicado a sua rede em outra zona AZ
  multi_az = var.multi_az

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  copy_tags_to_snapshot = true
  monitoring_role_arn   = aws_iam_role.rds_monitoring.arn

  # parte de rede
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]

  # utilizar um modulo secret manager para gerenciar esse segredo
  db_name  = var.db_name
  username = var.username
  password = var.password

  # comando para criar um backup do banco antes de aplicar o destroy
  # passei como variavel para alterar para cada ambiente , como dev e homog
  skip_final_snapshot = var.snapshot_enviroment
  # quero separar o nome para cada snapshot de acordo com o seu ambiente
  final_snapshot_identifier = var.name_snapshot_final
  # não quero deixar acessivel a internet
  publicly_accessible = false

}

# cria a Role e anexa a política oficial da AWS para monitoramento de banco de dados:
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.identifier_db}_monitoring_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}