#!/usr/bin/env bash

figlet -w 120 -f standard "Provision Oracle and Tomcat"

export RUNBATCH=$(echo `cat ./.runbatch`)
export VAULT_DNS=$(echo `cat ./.vault_dns`)
echo "VAULT at "$VAULT_DNS
export VAULT_TOKEN=$(echo `cat ./.vault_initial_root_token`)
echo "VAULT_TOKEN is "$VAULT_TOKEN

vault login -address="http://$VAULT_DNS:8200" $VAULT_TOKEN

vault kv get -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/dns | tee ./.temp
while read line
do
    echo "$line" | grep  "^dns\ *.*$" | xargs | cut -d ' ' -f2 > ./.value
    if [ -s "./.value" ]
        then
            export ORACLE_DNS=$(< ./.value)
    fi
done < ./.temp
rm ./.value ./.temp

vault kv get -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/dns | tee ./.temp
while read line
do
    echo "$line" | grep  "^dns\ *.*$" | xargs | cut -d ' ' -f2 > ./.value
    if [ -s "./.value" ]
        then
            export TOMCAT_DNS=$(< ./.value)
    fi
done < ./.temp
rm ./.value ./.temp

echo "ORACLE at "$ORACLE_DNS
echo "TOMCAT at "$TOMCAT_DNS

echo "Provision Oracle"
echo "upload: provision_oracle.sh to /home/ubuntu/provision_oracle.sh"
bolt file upload 'provision_oracle.sh' '/home/ubuntu/provision_oracle.sh' --nodes $ORACLE_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/provision_oracle.sh"
bolt command run 'chmod +x /home/ubuntu/provision_oracle.sh' --nodes $ORACLE_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: /home/ubuntu/provision_oracle.sh"
bolt command run '/home/ubuntu/provision_oracle.sh' --nodes $ORACLE_DNS --user 'ubuntu' --no-host-key-check

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/user user=system
vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/password password=oracle
vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/status status="provisioned"

vault kv get -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/user | tee ./.temp
while read line
do
    echo "$line" | grep  "^user\ *.*$" | xargs | cut -d ' ' -f2 > ./.value
    if [ -s "./.value" ]
        then
            export ORACLE_USER=$(< ./.value)
    fi
done < ./.temp
rm ./.value ./.temp

vault kv get -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/password | tee ./.temp
while read line
do
    echo "$line" | grep  "^password\ *.*$" | xargs | cut -d ' ' -f2 > ./.value
    if [ -s "./.value" ]
        then
            export ORACLE_PASSWORD=$(< ./.value)
    fi
done < ./.temp
rm ./.value ./.temp

echo "ORACLE_USER is "$ORACLE_USER
echo "ORACLE_PASSWORD is "$ORACLE_PASSWORD

echo "Build the liquibase.properties file for Liquibase to run against"
echo "driver: oracle.jdbc.driver.OracleDriver" > liquibase.properties
echo "classpath: lib/ojdbc8.jar" >> liquibase.properties
echo "url: jdbc:oracle:thin:@$ORACLE_DNS:1521:xe" >> liquibase.properties
echo "username: "$ORACLE_USER >> liquibase.properties
echo "password: "$ORACLE_PASSWORD >> liquibase.properties

echo "Create database schema and load sample data"
liquibase --changeLogFile=src/main/db/changelog.xml update

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/oracle/status status="test database created"

echo "Build fresh war for Tomcat deployment"
mvn -q clean compile war:war

echo "Build the oracleConfig.properties files for Tomcat war to run with"
echo "url=jdbc:oracle:thin:@$ORACLE_DNS:1521/xe" > oracleConfig.properties
echo "user="$ORACLE_USER >> oracleConfig.properties
echo "password="$ORACLE_PASSWORD >> oracleConfig.properties

echo "Provision Tomcat"
echo "upload: provision_tomcat.sh' to /home/ubuntu/provision_tomcat.sh"
bolt file upload 'provision_tomcat.sh' '/home/ubuntu/provision_tomcat.sh' --nodes $TOMCAT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/provision_tomcat.sh"
bolt command run 'chmod +x /home/ubuntu/provision_tomcat.sh' --nodes $TOMCAT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: oracleConfig.properties' to /home/ubuntu/oracleConfig.properties"
bolt file upload 'oracleConfig.properties' '/home/ubuntu/oracleConfig.properties' --nodes $TOMCAT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: target/passwordAPI.war' to /home/ubuntu/passwordAPI.war"
bolt file upload 'target/passwordAPI.war' '/home/ubuntu/passwordAPI.war' --nodes $TOMCAT_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: home/ubuntu/provision_tomcat.sh"
bolt command run '/home/ubuntu/provision_tomcat.sh' --nodes $TOMCAT_DNS --user 'ubuntu' --no-host-key-check

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/status status="provisioned"
