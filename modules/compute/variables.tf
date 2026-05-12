variable "compartment_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "javaagent"
}

variable "private_subnet_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "wallet_b64" {
  type      = string
  sensitive = true
}

variable "db_service_name" {
  type = string
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}

variable "oci_region" {
  type    = string
  default = "sa-santiago-1"
}
