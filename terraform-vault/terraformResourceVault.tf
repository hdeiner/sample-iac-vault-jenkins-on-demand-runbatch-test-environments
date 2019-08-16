resource "aws_instance" "ec2_vault" {
  count           = 1
  ami             = "ami-759bc50a"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.vault_key_pair.key_name
  security_groups = [aws_security_group.vault.name]
  tags = {
    Name = "sample-iac-vault-jenkins-on-demand-runbatch-test-environments Vault ${format("%03d", count.index)}"
  }
}

