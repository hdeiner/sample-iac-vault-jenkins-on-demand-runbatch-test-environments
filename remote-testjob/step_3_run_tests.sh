#!/usr/bin/env bash

figlet -w 120 -f standard "Run Tests"

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

echo Smoke test
echo "curl -s http://$TOMCAT_DNS:8080/passwordAPI/passwordDB"
curl -s http://$TOMCAT_DNS:8080/passwordAPI/passwordDB > temp
if grep -q "RESULT_SET" temp
then
    echo "SMOKE TEST SUCCESS"
    figlet -w 120 -f slant "Smoke Test Success"
    vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/status status="smoke tested"

    echo "Configuring test application to point to Tomcat endpoint"
    echo "hosturl=http://$TOMCAT_DNS:8080" > rest_webservice.properties

    echo "Run integration tests"
    mvn -q verify failsafe:integration-test
    vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/status status="integration tested"
else
    echo "SMOKE TEST FAILURE!!!"
    figlet -w 120 -f slant "Smoke Test Failure"
    vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/$RUNBATCH/tomcat/status status="smoke test failed"
fi
rm temp