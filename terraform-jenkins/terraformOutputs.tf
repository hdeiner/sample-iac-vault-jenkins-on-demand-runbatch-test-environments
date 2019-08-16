output "jenkins_dns" {
  value = [aws_instance.ec2_jenkins.*.public_dns]
}

output "jenkins_ip" {
  value = [aws_instance.ec2_jenkins.*.public_ip]
}

