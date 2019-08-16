#!/usr/bin/env bash

# First, add the GPG key for the official Docker repository to the system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Next, update the package database with the Docker packages from the newly added repo:
sudo apt-get -qq update

# Install Docker
sudo apt-get -qq install -y docker-ce

echo "Start the tomcat server"
sudo docker network create -d bridge mynetwork
sudo docker run -d -p 8080:8080 -v $(pwd)/target:/usr/local/tomcat/webapps/ --network=mynetwork --name tomcat tomcat:9.0.8-jre8

echo "Waiting for Tomcat to start"
while true ; do
  curl -s localhost:8080 > tmp.txt
  result=$(grep -c "HTTP Status 404 – Not Found" tmp.txt)
  if [ $result = 1 ] ; then
    echo "Tomcat has started"
    break
  fi
  sleep 1
done
rm tmp.txt

# Deploy the app to test
sudo docker cp oracleConfig.properties tomcat:/usr/local/tomcat/webapps/oracleConfig.properties
sudo docker cp passwordAPI.war tomcat:/usr/local/tomcat/webapps/passwordAPI.war

# Allow Tomcat time to digest
sleep 30
