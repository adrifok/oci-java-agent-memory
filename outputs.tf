output "vcn_id" {
  value = module.networking.vcn_id
}

output "app_private_ip" {
  value = module.compute.private_ip
}

output "adb_id" {
  value = module.database.adb_id
}

output "bastion_id" {
  value = module.bastion.bastion_id
}

