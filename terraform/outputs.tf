output "vm_ips" {
  description = "IP addresses of all VMs"
  value       = { for name, vm in module.vms : name => vm.vm_ip }
}

output "ssh_commands" {
  description = "SSH commands to connect to each VM"
  value       = { for name, vm in module.vms : name => "ssh root@${vm.vm_ip}" }
}

output "jumpbox_ssh_key_path" {
  description = "Path to the generated jumpbox private key"
  value       = "${path.module}/jumpbox_id_ed25519"
}
