output "vault_dns" {
  value = [aws_instance.ec2_vault.*.public_dns]
}

output "vault_ip" {
  value = [aws_instance.ec2_vault.*.public_ip]
}

