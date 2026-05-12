data "oci_identity_availability_domains" "main" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.main.availability_domains[0].name
  display_name        = "${var.project_name}-app"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = var.private_subnet_id
    assign_public_ip = false
    display_name     = "${var.project_name}-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.cloud_init)
  }

  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
}

locals {
  cloud_init = <<-EOF
    #!/bin/bash
    dnf install -y java-17-openjdk unzip

    mkdir -p /opt/javaagent/wallet
    echo "${var.wallet_b64}" | base64 -d > /opt/javaagent/wallet/wallet.zip
    unzip -o /opt/javaagent/wallet/wallet.zip -d /opt/javaagent/wallet/

    cat <<ENV > /opt/javaagent/.env
    DB_WALLET_PATH=/opt/javaagent/wallet
    DB_SERVICE=${var.db_service_name}
    DB_USER=ADMIN
    DB_PASSWORD=${var.db_admin_password}
    OCI_GENAI_REGION=${var.oci_region}
    ENV

    # app jar will be placed here via CI or manual scp through bastion
    touch /opt/javaagent/.deployed
  EOF
}
