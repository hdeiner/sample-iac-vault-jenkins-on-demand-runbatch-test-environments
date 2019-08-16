#!/usr/bin/env bash

figlet -w 160 -f standard "Terraform Jenkins"

cd terraform-jenkins
terraform init
terraform apply -auto-approve
echo `terraform output jenkins_dns | grep -o '".*"' | cut -d '"' -f2` > ../.jenkins_dns
cd ..

export VAULT_DNS=$(echo `cat ./.vault_dns`)
echo "VAULT at "$VAULT_DNS
export VAULT_TOKEN=$(echo `cat ./.vault_initial_root_token`)
echo "VAULT_TOKEN is "$VAULT_TOKEN

export JENKINS=$(echo `cat ./.jenkins_dns`)
echo "JENKINS at "JENKINS

vault login -address="http://$VAULT_DNS:8200" $VAULT_TOKEN
vault secrets enable -address="http://$VAULT_DNS:8200" -version=2 -path=SYSTEMS_CONFIG kv

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/dns dns=$JENKINS
vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/status status="not provisioned"
