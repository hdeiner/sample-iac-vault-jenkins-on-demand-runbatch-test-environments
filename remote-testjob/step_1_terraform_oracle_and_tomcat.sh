#!/usr/bin/env bash

figlet -w 120 -f standard "Terraform Oracle and Tomcat"

cd terraform-oracle-tomcat
terraform init
terraform apply -auto-approve
echo `terraform output oracle_dns | grep -o '".*"' | cut -d '"' -f2` > ../.oracle_dns
echo `terraform output tomcat_dns | grep -o '".*"' | cut -d '"' -f2` > ../.tomcat_dns
cd ..

export VAULT_DNS=$(echo `cat ./.vault_dns`)
echo "VAULT at "$VAULT_DNS
export VAULT_TOKEN=$(echo `cat ./.vault_initial_root_token`)
echo "VAULT_TOKEN is "$VAULT_TOKEN

export ORACLE=$(echo `cat ./.oracle_dns`)
export TOMCAT=$(echo `cat ./.tomcat_dns`)
echo "ORACLE at "$ORACLE
echo "TOMCAT at "$TOMCAT

echo "INCENTIVES/DESKTOP_TEST/AWS_HOSTED_CONTAINERS/howard.deiner/"`date +%Y%m%d%H%M%S` > ./.runbatch
export RUNBATCH=$(echo `cat ./.runbatch`)

vault login -address="http://$VAULT_DNS:8200" $VAULT_TOKEN
vault secrets enable -address="http://$VAULT_DNS:8200" -version=2 -path=SYSTEMS_CONFIG kv

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/dns dns=$ORACLE
vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/status status="not provisioned"

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/dns dns=$TOMCAT
vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/status status="not provisioned"
