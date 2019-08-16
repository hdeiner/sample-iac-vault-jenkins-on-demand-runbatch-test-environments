#!/usr/bin/env bash

figlet -w 120 -f standard "Teardown Everything"

cd terraform-jenkins
terraform destroy -auto-approve
cd ..

cd terraform-vault
terraform destroy -auto-approve
cd ..

rm ~/.vault_dns ~/.vault_initial_root_token ~/.jenkins_dns