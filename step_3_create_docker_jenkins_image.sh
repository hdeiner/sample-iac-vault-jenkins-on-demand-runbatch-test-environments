#!/usr/bin/env bash

figlet -w 160 -f standard "Build and Push Jenkins Docker Image"

figlet -w 160 -f slant "Docker Housekeeping"
docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home

docker rmi howarddeiner/jenkins:latest

figlet -w 160 -f slant "Build Jenkins Image"
docker build docker-jenkins -t howarddeiner/jenkins:latest

figlet -w 160 -f slant "Push Jenkins Image"
docker login
docker push howarddeiner/jenkins:latest