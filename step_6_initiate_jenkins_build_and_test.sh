#!/bin/bash

figlet -w 160 -f standard "Initiate Jenkins TESTJOB"

# NOTES
#
# Retrieve the XML document for the TEST job on the Jenkins server
# curl -X GET http://[jenkinsserver]/job/TEST/config.xml -u admin:admin
#

export JENKINS_DNS=$(echo `cat ~/.jenkins_dns`)
echo "JENKINS at "$JENKINS_DNS

figlet -w 160 -f slant "Create Jenkins TESTJOB"
curl -s -XPOST "http://$JENKINS_DNS/createItem?name=TESTJOB" -u admin:admin --data-binary @remote-testjob/jenkins_testjob.xml -H "Content-Type:text/xml"

figlet -w 160 -f slant "Build Jenkins TESTJOB"
curl -s -XPOST "http://$JENKINS_DNS/job/TESTJOB/build" -u admin:admin

echo "Check http://$JENKINS_DNS for build artifacts"