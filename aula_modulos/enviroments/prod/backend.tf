terraform {
  backend "s3" {

    bucket = "meu-bucket-terraform"
    # key é como se fosse o caminho da pasta onde sera guardado o arquivo.tfstate
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"

  }
}