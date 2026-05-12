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

