output "adb_id" {
  value = oci_database_autonomous_database.main.id
}

output "adb_connection_strings" {
  value     = oci_database_autonomous_database.main.connection_strings
  sensitive = true
}

output "wallet_path" {
  value = local_file.wallet.filename
}
