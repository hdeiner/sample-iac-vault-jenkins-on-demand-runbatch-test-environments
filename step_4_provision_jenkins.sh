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

NOW FOR THE HARD WORK OF TERRAFORMING AND PROVISIONING for an AWS instance to house a container for this image