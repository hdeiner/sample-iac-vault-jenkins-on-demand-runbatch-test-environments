#!/usr/bin/env bash

figlet -w 160 -f standard "Initiate Jenkins TESTJOB"


docker run -d -p 80:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins howarddeiner/jenkins:latest

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