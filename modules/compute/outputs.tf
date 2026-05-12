output "instance_id" {
  value = oci_core_instance.app.id
}

output "private_ip" {
  value = oci_core_instance.app.private_ip
}
