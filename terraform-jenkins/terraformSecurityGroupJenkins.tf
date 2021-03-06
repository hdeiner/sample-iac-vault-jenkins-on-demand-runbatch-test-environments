resource "aws_security_group" "jenkins" {
  name        = "docker-oracle-jenkins-tomcat-terraform-aws-bolt-sample-jenkins"
  description = "docker-oracle-tomcat-jenkins-terraform-aws-bolt-sample jenkins Access"
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 8200
    to_port   = 8200
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "sample-iac-vault-jenkins-on-demand-runbatch-test-environments jenkins Access"
  }
}

