variable "cidr_block" {
  type = string
}

variable "cidr_block_public" {
  type = string
}

variable "cidr_block_private" {
  type = string
}

variable "network_public" {
  type = string
}

variable "network_private" {
  type = string
}

variable "name_network" {
  description = "Nome da VPC"
  type        = string
}


variable "cidr_rds_a" {
  type = string
}

variable "cidr_rds_b" {
  type = string
}

variable "avaibility_zone_a" {
  type = string
}

variable "avaibility_zone_b" {
  type = string
}