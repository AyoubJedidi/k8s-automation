output "vm_ip" {
  value = var.ip
}

output "vm_name" {
  value = lxd_instance.vm.name
}
