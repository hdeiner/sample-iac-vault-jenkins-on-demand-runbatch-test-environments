FROM jenkins/jenkins:latest

#RUN /usr/local/bin/install-plugins.sh git matrix-auth workflow-aggregator docker-workflow blueocean credentials-binding
RUN /usr/local/bin/install-plugins.sh git

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home

# Install mvn, figlet, terraform, and vault
USER root
RUN apt-get update && apt-get install -y maven && apt-get install -y figlet
RUN wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
RUN unzip terraform_0.12.6_linux_amd64.zip
RUN mv terraform /usr/local/bin/
RUN wget https://releases.hashicorp.com/vault/1.2.2/vault_1.2.2_linux_amd64.zip
RUN unzip vault_1.2.2_linux_amd64.zip
RUN mv vault /usr/local/bin/
USER jenkins

