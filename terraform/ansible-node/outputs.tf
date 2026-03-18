output "ansible_public_ip" {
  value = aws_instance.ansible.public_ip
}