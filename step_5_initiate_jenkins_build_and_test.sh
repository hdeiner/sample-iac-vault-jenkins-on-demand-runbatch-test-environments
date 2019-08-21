#!/usr/bin/env bash

figlet -w 160 -f standard "Initiate Jenkins TESTJOB"

#docker stop jenkins
#docker rm jenkins
#docker volume rm jenkins_home

#figlet -w 160 -f slant "Create Jenkins Docker Container"
#docker run -d -p 80:8080 -p 8200:8200 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins howarddeiner/jenkins:latest
#
#figlet -w 160 -f slant "Waiting for Jenkins to start"
#while true ; do
#  curl -s localhost > tmp.txt
#  result=$(grep -c "Dashboard \[Jenkins\]" tmp.txt)
#  if [ $result = 1 ] ; then
#    echo "Jenkins has started"
#    break
#  fi
#  sleep 5
#done
#rm tmp.txt

#figlet -w 160 -f slant "ssh credentials for Jenkins"
#
#docker exec jenkins mkdir /var/jenkins_home/.ssh
#docker exec jenkins ssh-keygen -t rsa -b 2048 -f "/var/jenkins_home/.ssh/id_rsa" -q
#
#figlet -w 160 -f slant "AWS credentials for Jenkins"
#
## Use my credentials for AWS
#docker exec jenkins mkdir /var/jenkins_home/.aws
#docker cp /home/howarddeiner/.aws/config jenkins:/var/jenkins_home/.aws/config
#docker cp /home/howarddeiner/.aws/credentials jenkins:/var/jenkins_home/.aws/credentials
#
#figlet -w 160 -f slant "Burn in Vault access into Jenkins"
#
## Burn in Vault access
#docker cp /home/howarddeiner/.vault_dns jenkins:/var/jenkins_home/.vault_dns
#docker cp /home/howarddeiner/.vault_initial_root_token jenkins:/var/jenkins_home/.vault_initial_root_token

# NOTES
#
# Retrieve the XML document for the TEST job on the Jenkins server
# curl -X GET http://localhost/job/TEST/config.xml -u admin:admin
#

export JENKINS_DNS=$(echo `cat ~/.jenkins_dns`)
echo "JENKINS at "$JENKINS_DNS

figlet -w 160 -f slant "Create Jenkins TESTJOB"
curl -s -XPOST "http://$JENKINS_DNS/createItem?name=TESTJOB" -u admin:admin --data-binary @remote-testjob/jenkins_testjob.xml -H "Content-Type:text/xml"

figlet -w 160 -f slant "Build Jenkins TESTJOB"
curl -s -XPOST "http://$JENKINS_DNS/job/TESTJOB/build" -u admin:admin

echo "Check http://$JENKINS_DNS for build artifacts"