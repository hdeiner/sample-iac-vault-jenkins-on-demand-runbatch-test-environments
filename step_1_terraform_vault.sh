#!/bin/bash

figlet -w 160 -f standard "Terraform Vault"

cd terraform-vault
terraform init
terraform apply -auto-approve
echo `terraform output vault_dns | grep -o '".*"' | cut -d '"' -f2` > ~/.vault_dns
cd ..
