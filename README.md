oci-java-agent-memory

Terraform IaC that runs Oracle's Java AI agent with long-term memory on OCI. The agent keeps its memory in an Autonomous Database and calls OCI Generative AI. The app comes from Oracle AI Developer Hub (apps/oracle-database-java-agent-memory). This repo is the platform around it: network, database, compute and access.

The agent was deployed and run on this infrastructure. No screenshots were kept.


Architecture

  Internet
    |
  OCI Bastion (STANDARD, allow-list = your IP, 3h max session)
    |
  private subnet ---- app VM (VM.Standard.E2.1.Micro, Oracle Linux 8, no public IP)
    |                     |
  NAT gateway             +---- Autonomous Database (ATP, free tier, wallet auth)
    |                     +---- OCI Generative AI
  Internet (outbound only)


What gets created (14 resources)

  networking   VCN, public and private subnets, internet gateway, NAT gateway, two route tables, two security lists
  database     Autonomous Database (ATP free tier) and its wallet, also written to wallet/wallet.zip locally
  compute      private instance; cloud-init installs Java 17, unpacks the wallet to /opt/javaagent/wallet and writes /opt/javaagent/.env
  bastion      OCI Bastion service limited to my_public_ip_cidr


Deploy the infrastructure

  cp terraform.tfvars.example terraform.tfvars
  export TF_VAR_db_admin_password='...'
  export TF_VAR_wallet_password='...'
  terraform init
  terraform plan -out=tfplan
  terraform apply tfplan

  terraform.tfvars, the state and wallet/ are in .gitignore. The state holds the wallet and the DB password, so keep it out of git and out of shared machines.


Access the VM through Bastion

  The OCI CLI commands create-port-forwarding and create-managed-ssh failed with "TypeError: unexpected keyword argument 'ssh_public_key_file'". The workaround is to call the API directly with oci raw-request and a JSON body.

  1. Create a port-forwarding session. Write the body to a file:

     {"bastionId":"<BASTION_ID>","displayName":"oci-pf","sessionTtlInSeconds":10800,"keyDetails":{"publicKeyContent":"<SSH_PUBLIC_KEY>"},"targetResourceDetails":{"sessionType":"PORT_FORWARDING","targetResourcePrivateIpAddress":"<APP_PRIVATE_IP>","targetResourcePort":22}}

     oci raw-request --http-method POST --target-uri "https://bastion.<REGION>.oci.oraclecloud.com/20210331/sessions" --request-body file://session.json

  2. Wait for the session to be ACTIVE, then open the tunnel in its own terminal:

     ssh -i ~/.ssh/<KEY> -N -L 2222:<APP_PRIVATE_IP>:22 -o ServerAliveInterval=30 -o ServerAliveCountMax=10 <SESSION_OCID>@host.bastion.<REGION>.oci.oraclecloud.com

  3. Connect:

     ssh -i ~/.ssh/<KEY> -p 2222 opc@127.0.0.1

  bastion_id and app_private_ip come from terraform output.


Deploy the agent

  Terraform prepares the VM but does not ship the app. Build the jar following the upstream app README, then copy it through the tunnel and start it with the generated .env loaded.

     scp -i ~/.ssh/<KEY> -P 2222 <APP_JAR> opc@127.0.0.1:/tmp/app.jar

     ssh -i ~/.ssh/<KEY> -p 2222 opc@127.0.0.1 'sudo mv /tmp/app.jar /opt/javaagent/app.jar && set -a && . /opt/javaagent/.env && set +a && nohup java -jar /opt/javaagent/app.jar > /tmp/app.log 2>&1 &'


Lessons learned

  Bastion sessions expire after 3 hours and the tunnel drops without warning. Every reconnect needs a new session and a new tunnel.

  On Oracle Linux 8, sshd did not come up reliably after the first boot. A reset of the instance fixed it.

  cloud-init runs dnf install on a 1 GB micro shape, which is slow. Check /var/log/cloud-init-output.log before assuming Java is missing.

  OCI Cloud Shell has direct access to private subnets. For a lab like this it is simpler than Bastion: no sessions, no tunnel.


Known trade-offs

  The wallet and the DB admin password go to the VM inside user_data. Instance metadata is readable from inside the VM and the values also sit in the Terraform state. That is acceptable for a free-tier lab, not for production. The production fix is OCI Vault for the secrets and a dedicated DB user with least privilege instead of ADMIN.

  The Autonomous Database has lifecycle ignore_changes = all, so Terraform will not update it after creation.


Clean up

  terraform plan -destroy
  terraform destroy

  The ATP instance is Always Free, but the VM, Bastion and NAT gateway still count against tenancy limits.
