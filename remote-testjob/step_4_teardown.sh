#!/usr/bin/env bash

figlet -w 120 -f standard "Teardown Everything"

cd terraform-oracle-tomcat
terraform destroy -auto-approve
cd ..

rm ./.oracle_dns ./.tomcat_dns ./.runbatch liquibase.properties oracleConfig.properties rest_webservice.properties