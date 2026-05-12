resource "oci_bastion_bastion" "main" {
  compartment_id               = var.compartment_id
  bastion_type                 = "STANDARD"
  target_subnet_id             = var.private_subnet_id
  name                         = "${var.project_name}bastion"
  client_cidr_block_allow_list = [var.allowed_cidr]
  max_session_ttl_in_seconds   = 10800
}
