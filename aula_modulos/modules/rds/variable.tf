variable "engine_db" {
  type = string
}

variable "engine_version_db" {
  type = string
}

variable "instance_type" {
  type = string
}

# criar um map no main variable para os tipos de valores do engine

variable "db_name" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "identifier_db" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "vpc_security_group_ids" {

  type = string

}

# criaar uma variavel para separar o nome dos snapshot por ambiente
variable "name_snapshot_final" {
  type = string
}

variable "rds_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "multi_az" {

  type = bool

}

variable "deletion_protection" {
  type = bool
}

variable "snapshot_enviroment" {
  type = bool
}