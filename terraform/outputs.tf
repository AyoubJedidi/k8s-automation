output "vm_ips" {
  description = "IP addresses of all VMs"
  value       = { for name, cfg in var.vms : name => cfg.ip }
}

output "ssh_commands" {
  description = "SSH commands to connect to each VM"
  value       = { for name, cfg in var.vms : name => "ssh root@${cfg.ip}" }
}

output "jumpbox_ssh_key_path" {
  description = "Path to the generated jumpbox private key"
  value       = "${path.module}/jumpbox_id_ed25519"
}
