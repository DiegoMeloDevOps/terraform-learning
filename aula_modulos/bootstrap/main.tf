# criei o recurso mas preciso associar um tabela dynamo para ela armazenar o arquivo
resource "aws_s3_bucket" "meu_bucket_terraform" {
  bucket = "meu-bucket-terraform"

  # para impedir que ao rodar "destroy" o bucket seje destruido
  lifecycle {
    prevent_destroy = true
  }
}

# Preciso criar a tabela que sera usada pelo o bucket s3, para termos a segurança do locking
# assim evito erro de corromper o arquivo tf.state por 2 apply ao mesmo tempo
# posso utilizar a mesma tabela do dynamo para armazenar os estados , oque vai mudar no meu bucket
# é a key, que seria o local que sera armazenado
resource "aws_dynamodb_table" "terraform_lock" {

  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  # funciona como a chave primaria da tabela
  hash_key = "LockID"

  # o atributo é para setar a estrutura da chave, seu nome e seu tipo de dado "s" = string
  attribute {
    name = "LockID"
    type = "S"
  }

}

resource "aws_s3_bucket_public_access_block" "s3_block_public_acess" {

  bucket = aws_s3_bucket.meu_bucket_terraform.id

  # para impedir qualquer acesso ou ser exposto para a internet acidentalmente
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_versioning" "s3_bucket_version" {

  bucket = aws_s3_bucket.meu_bucket_terraform.id

  # para permitir versionamento para recuperar arquivos apagados ou versões anteriores
  versioning_configuration {
    status = "Enabled"
  }

}