variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

# para mudar o nome do segredo por ambiente
variable "rds_name" {
  type = string

}