module "networking" {
  source         = "./modules/networking"
  compartment_id = var.compartment_id
  project_name   = var.project_name
}

module "database" {
  source              = "./modules/database"
  compartment_id      = var.compartment_id
  project_name        = var.project_name
  db_name             = var.db_name
  db_admin_password   = var.db_admin_password
  wallet_password     = var.wallet_password
}

module "compute" {
  source             = "./modules/compute"
  compartment_id     = var.compartment_id
  project_name       = var.project_name
  private_subnet_id  = module.networking.private_subnet_id
  ssh_public_key     = var.ssh_public_key
  wallet_b64         = module.database.wallet_path
  db_service_name    = "${var.db_name}_high"
  db_admin_password  = var.db_admin_password
  oci_region         = var.region

  depends_on = [module.database]
}

module "bastion" {
  source              = "./modules/bastion"
  compartment_id      = var.compartment_id
  project_name        = var.project_name
  private_subnet_id   = module.networking.private_subnet_id
  allowed_cidr   = var.my_public_ip_cidr
  ssh_public_key = var.ssh_public_key

  depends_on = [module.compute]
}
