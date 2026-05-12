variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type    = string
  default = "sa-santiago-1"
}

variable "compartment_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "javaagent"
}

variable "db_name" {
  type    = string
  default = "javaagentdb"
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}

variable "wallet_password" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "my_public_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR notation, e.g. 1.2.3.4/32"
}
