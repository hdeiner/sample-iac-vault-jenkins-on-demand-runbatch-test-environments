#!/bin/bash

# First, add the GPG key for the official Docker repository to the system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Next, update the package database with the Docker packages from the newly added repo:
sudo apt-get -qq update

# Install Docker
sudo apt-get -qq install -y docker-ce

echo "Start the Jenkins server"
sudo docker network create -d bridge mynetwork
sudo docker run -d -p 80:8080 -p 8200:8200 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins howarddeiner/jenkins:latest

echo "Waiting for Jenkins to start"
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
