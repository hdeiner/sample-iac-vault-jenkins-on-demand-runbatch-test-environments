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

# Install ssh keys, mvn, figlet, terraform, vault, liquibase, and bolt
USER root
# Maven  anf figlet
RUN apt-get update && apt-get install -y maven && apt-get install -y figlet
# Terrafirn
RUN wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
RUN unzip terraform_0.12.6_linux_amd64.zip
RUN mv terraform /usr/local/bin/
# Vault (for client)
RUN wget https://releases.hashicorp.com/vault/1.2.2/vault_1.2.2_linux_amd64.zip
RUN unzip vault_1.2.2_linux_amd64.zip
RUN mv vault /usr/local/bin/
# Liquibase
RUN wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.7.0/liquibase-3.7.0-bin.tar.gz
RUN tar zxvf liquibase-3.7.0-bin.tar.gz
RUN chmod +x ./liquibase
RUN ln -s /liquibase /usr/local/bin/liquibase
# Bolt
RUN wget https://apt.puppet.com/puppet-tools-release-xenial.deb
RUN dpkg -i puppet-tools-release-xenial.deb
RUN apt-get update
RUN apt-get install -y puppet-bolt
#
USER jenkins

