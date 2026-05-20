# oci-java-agent-memory

Terraform IaC to deploy Oracle's Java AI agent with Autonomous Database on OCI. Multi-tier architecture: private compute with no public IP, OCI Bastion service for SSH access, and an ATP free-tier database.

What gets deployed

VCN with a private subnet, an OCI Compute instance running the Java agent, an Autonomous Database (ATP free tier) with wallet-based auth, and an OCI Bastion session as the only SSH entry point.

Modules

- `networking` — VCN, private subnet
- `database` — Autonomous Database (ATP), wallet generation
- `compute` — private instance, wallet injection, DB connection config
- `bastion` — OCI Bastion service, SSH access restricted to your IP

Usage

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

Variables

- `tenancy_ocid` — OCI tenancy OCID
- `user_ocid` — OCI user OCID
- `fingerprint` — API key fingerprint
- `private_key_path` — path to OCI API private key
- `region` — OCI region (default: `sa-santiago-1`)
- `compartment_id` — target compartment OCID
- `project_name` — resource name prefix (default: `javaagent`)
- `db_name` — Autonomous DB name (default: `javaagentdb`)
- `db_admin_password` — ATP admin password (sensitive)
- `wallet_password` — ATP wallet password (sensitive)
- `ssh_public_key` — your SSH public key content
- `my_public_ip_cidr` — your IP in CIDR notation, e.g. `1.2.3.4/32`
