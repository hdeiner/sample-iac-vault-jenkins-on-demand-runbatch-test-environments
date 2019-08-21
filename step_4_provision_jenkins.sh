#!/usr/bin/env bash

figlet -w 160 -f standard "Provision Jenkins"

figlet -w 160 -f slant "Build and Push Jenkins Docker Image"

docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home

docker rmi howarddeiner/jenkins:latest

docker login
docker build docker-jenkins -t howarddeiner/jenkins:latest
docker push howarddeiner/jenkins:latest

figlet -w 120 -f standard "Provision Jenkins"

export VAULT_DNS=$(echo `cat ./.vault_dns`)
echo "VAULT at "$VAULT_DNS
export VAULT_TOKEN=$(echo `cat ./.vault_initial_root_token`)
echo "VAULT_TOKEN is "$VAULT_TOKEN

vault login -address="http://$VAULT_DNS:8200" $VAULT_TOKEN

vault kv get -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/dns | tee ./.temp
while read line
do
    echo "$line" | grep  "^dns\ *.*$" | xargs | cut -d ' ' -f2 > ./.value
    if [ -s "./.value" ]
        then
            export JENKINS_DNS=$(< ./.value)
    fi
done < ./.temp
rm ./.value ./.temp

echo "JENKINS at "$JENKINS_DNS

echo "upload: provision_jenkins.sh to /home/ubuntu/provision_jenkins.sh"
bolt file upload 'provision_jenkins.sh' '/home/ubuntu/provision_jenkins.sh' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: chmod +x /home/ubuntu/provision_jenkins.sh"
bolt command run 'chmod +x /home/ubuntu/provision_jenkins.sh' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: /home/ubuntu/provision_jenkins.sh"
bolt command run '/home/ubuntu/provision_jenkins.sh' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/status status="provisioned"

figlet -w 160 -f slant "ssh credentials for Jenkins"

echo "remote execution: mkdir /var/jenkins_home/.ssh"
bolt command run 'mkdir /var/jenkins_home/.ssh' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: ssh-keygen -t rsa -b 2048 -f '/var/jenkins_home/.ssh/id_rsa' -q"
bolt command run 'ssh-keygen -t rsa -b 2048 -f "/var/jenkins_home/.ssh/id_rsa" -q' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check

figlet -w 160 -f slant "AWS credentials for Jenkins"

# Use my credentials for AWS
echo "remote execution: mkdir /var/jenkins_home/.aws"
bolt command run 'mkdir /var/jenkins_home/.aws' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.aws/config to /var/jenkins_home/.aws/config"
bolt file upload '/home/howarddeiner/.aws/config' '/var/jenkins_home/.aws/config' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.aws/config to /var/jenkins_home/.aws/config"
bolt file upload '/home/howarddeiner/.aws/credentials' '/var/jenkins_home/.aws/credentials' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check

figlet -w 160 -f slant "Burn in Vault access into Jenkins"

# Burn in Vault access
echo "upload: /home/howarddeiner/.vault_dns to /var/jenkins_home/.vault_dns"
bolt file upload '/home/howarddeiner/.vault_dns' '/var/jenkins_home/.vault_dns' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.vault_initial_root_token jenkins to /var/jenkins_home/.vault_initial_root_token jenkins"
bolt file upload '/home/howarddeiner/.vault_initial_root_token jenkins' '/var/jenkins_home/.vault_initial_root_token jenkins' --nodes $VAULT_DNS --user 'ubuntu' --no-host-key-check

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/status status="ready for work"
