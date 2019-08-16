resource "aws_instance" "ec2_tomcat" {
  count           = 1
  ami             = "ami-759bc50a"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.aws_key_pair.key_name
  security_groups = [aws_security_group.tomcat.name]
  tags = {
    Name = "sample-iac-vault-jenkins-on-demand-runbatch-test-environments Tomcat ${format("%03d", count.index)}"
  }
}

