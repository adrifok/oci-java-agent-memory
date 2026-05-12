resource "oci_database_autonomous_database" "main" {
  compartment_id           = var.compartment_id
  db_name                  = var.db_name
  display_name             = "${var.project_name}-adb"
  db_workload              = "OLTP"
  is_free_tier             = true
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  admin_password = var.db_admin_password

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_database_autonomous_database_wallet" "main" {
  autonomous_database_id = oci_database_autonomous_database.main.id
  password               = var.wallet_password
  base64_encode_content  = true
}

resource "local_file" "wallet" {
  content_base64 = oci_database_autonomous_database_wallet.main.content
  filename       = "${path.root}/wallet/wallet.zip"
}
