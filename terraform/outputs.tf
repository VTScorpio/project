output "instance_ip" {
  value       = aws_instance.monitor_vm.public_ip
  description = "IP-ul public al instanței EC2"
}
