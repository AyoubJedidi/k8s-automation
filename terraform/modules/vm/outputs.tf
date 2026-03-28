output "vm_ip" {
  value = multipass_instance.vm.ipv4[0]
}

output "vm_name" {
  value = multipass_instance.vm.name
}
