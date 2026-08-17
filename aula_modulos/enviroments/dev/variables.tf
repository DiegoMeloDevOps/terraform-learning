variable "db_username" {
  type        = string
  description = "senha do banco"
  sensitive   = true

}

variable "db_password" {
  type        = string
  description = "senha do banco"
  sensitive   = true
}

variable "region_aws" {
  type = string
  default = "us-east-1"
}