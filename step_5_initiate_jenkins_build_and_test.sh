#!/usr/bin/env bash

figlet -w 160 -f standard "Initiate Jenkins TESTJOB"

docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home

figlet -w 160 -f slant "Create Jenkins Docker Container"
docker run -d -p 80:8080 -p 8200:8200 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins howarddeiner/jenkins:latest

figlet -w 160 -f slant "Waiting for Jenkins to start"
while true ; do
  curl -s localhost > tmp.txt
  result=$(grep -c "Dashboard \[Jenkins\]" tmp.txt)
  if [ $result = 1 ] ; then
    echo "Jenkins has started"
    break
  fi
  sleep 5
done
rm tmp.txt

figlet -w 160 -f slant "Put credentia;s into Jenkins"
# Use my credentials for ssh
docker exec jenkins mkdir /var/jenkins_home/.ssh
docker cp /home/howarddeiner/.ssh/id_rsa.pub jenkins:/var/jenkins_home/.ssh/id_rsa.pub

# Use my credentials for ssh
docker exec jenkins mkdir /var/jenkins_home/.aws
docker cp /home/howarddeiner/.aws/config jenkins:/var/jenkins_home/.aws/config
docker cp /home/howarddeiner/.aws/credentials jenkins:/var/jenkins_home/.aws/credentials

# Burn in Vault access
docker cp /home/howarddeiner/.vault_dns jenkins:/var/jenkins_home/.vault_dns
docker cp /home/howarddeiner/.vault_initial_root_token jenkins:/var/jenkins_home/.vault_initial_root_token

# NOTES
#
# Retrieve the XML document for the TEST job on the Jenkins server
# curl -X GET http://localhost/job/TEST/config.xml -u admin:admin
#

figlet -w 160 -f slant "Create Jenkins TESTJOB"
curl -s -XPOST "http://localhost/createItem?name=TESTJOB" -u admin:admin --data-binary @remote-testjob/jenkins_testjob.xml -H "Content-Type:text/xml"

figlet -w 160 -f slant "Build Jenkins TESTJOB"
curl -s -XPOST "http://localhost/job/TESTJOB/build" -u admin:admin

echo "Check http://localhost for build... artifacts"