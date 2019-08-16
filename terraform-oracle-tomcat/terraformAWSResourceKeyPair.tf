resource "aws_key_pair" "oracle_tomcat_key_pair" {
  key_name   = "oracle_tomcat_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

