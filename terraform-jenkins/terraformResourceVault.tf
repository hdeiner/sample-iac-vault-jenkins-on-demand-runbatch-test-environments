resource "aws_instance" "ec2_jenkins" {
  count           = 1
  ami             = "ami-759bc50a"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.jenkins_key_pair.key_name
  security_groups = [aws_security_group.jenkins.name]
  tags = {
    Name = "sample-iac-vault-jenkins-on-demand-runbatch-test-environments jenkins ${format("%03d", count.index)}"
  }
}

