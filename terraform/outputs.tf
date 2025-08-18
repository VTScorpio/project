output "instance_ip" {
  value       = aws_instance.monitor_vm.public_ip
  description = "IP-ul public al instanței EC2 (simulat de LocalStack)"
}

output "ssh_key_name" {
  description = "Numele perechii de chei SSH"
  value       = aws_key_pair.main_key.key_name
}

output "ssh_public_key" {
  description = "Cheia publica asociata perechii SSH"
  value       = aws_key_pair.main_key.public_key
  sensitive   = false
}

output "instance_id" {
  description = "ID-ul instanței EC2 (simulat de LocalStack)"
  value       = aws_instance.monitor_vm.id
}

output "instance_url" {
  description = "Acces web (placeholder)"
  value       = "http://${aws_instance.monitor_vm.public_ip}:80"
  sensitive   = false
}