#!/bin/bash

figlet -w 160 -f standard "Provision Jenkins"

export VAULT_DNS=$(echo `cat ~/.vault_dns`)
echo "VAULT at "$VAULT_DNS
export VAULT_TOKEN=$(echo `cat ~/.vault_initial_root_token`)
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

echo "remote execution: sudo docker exec jenkins mkdir /var/jenkins_home/.ssh"
bolt command run 'sudo docker exec jenkins mkdir /var/jenkins_home/.ssh' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker exec jenkins ssh-keygen -t rsa -b 2048 -f '/var/jenkins_home/.ssh/id_rsa' -q"
bolt command run 'sudo docker exec jenkins ssh-keygen -t rsa -b 2048 -f "/var/jenkins_home/.ssh/id_rsa" -q' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check

figlet -w 160 -f slant "AWS credentials for Jenkins"

# Use my credentials for AWS
echo "remote execution: mkdir /home/ubuntu/.aws"
bolt command run 'mkdir /home/ubuntu/.aws' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker exec jenkins mkdir /var/jenkins_home/.aws"
bolt command run 'sudo docker exec jenkins mkdir /var/jenkins_home/.aws' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.aws/config to /home/ubuntu/.aws/config"
bolt file upload '/home/howarddeiner/.aws/config' '/home/ubuntu/.aws/config' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker cp /home/ubuntu/.aws/config jenkins:/var/jenkins_home/.aws/config"
bolt command run 'sudo docker cp /home/ubuntu/.aws/config jenkins:/var/jenkins_home/.aws/config' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.aws/credentials to /home/ubuntu/.aws/credentials"
bolt file upload '/home/howarddeiner/.aws/credentials' '/home/ubuntu/.aws/credentials' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker cp /home/ubuntu/.aws/credentials jenkins:/var/jenkins_home/.aws/credentials"
bolt command run 'sudo docker cp /home/ubuntu/.aws/credentials jenkins:/var/jenkins_home/.aws/credentials' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check

figlet -w 160 -f slant "Burn in Vault access into Jenkins"

# Burn in Vault access
echo "upload: /home/howarddeiner/.vault_dns to /home/ubuntu/.vault_dns"
bolt file upload '/home/howarddeiner/.vault_dns' '/home/ubuntu/.vault_dns' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker cp /home/ubuntu/.vault_dns jenkins:/var/jenkins_home/.vault_dns"
bolt command run 'sudo docker cp /home/ubuntu/.vault_dns jenkins:/var/jenkins_home/.vault_dns' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "upload: /home/howarddeiner/.vault_initial_root_token to /home/ubuntu/.vault_initial_root_token"
bolt file upload '/home/howarddeiner/.vault_initial_root_token' '/home/ubuntu/.vault_initial_root_token' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check
echo "remote execution: sudo docker cp /home/ubuntu/.vault_initial_root_token jenkins:/var/jenkins_home/.vault_initial_root_token"
bolt command run 'sudo docker cp /home/ubuntu/.vault_initial_root_token jenkins:/var/jenkins_home/.vault_initial_root_token' --nodes $JENKINS_DNS --user 'ubuntu' --no-host-key-check

vault kv put -address="http://$VAULT_DNS:8200" SYSTEMS_CONFIG/jenkins/status status="ready for work"
