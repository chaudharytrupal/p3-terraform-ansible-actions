output "public_ip_bastion" {
  value = aws_instance.bastion.public_ip
}
