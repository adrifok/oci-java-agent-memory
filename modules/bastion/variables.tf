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

variable "allowed_cidr" {
  type        = string
  description = "Your public IP in CIDR notation, e.g. 1.2.3.4/32"
}

variable "ssh_public_key" {
  type = string
}

