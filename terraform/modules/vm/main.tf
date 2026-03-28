terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.0.3"
    }
  }
}

resource "multipass_instance" "vm" {
  name   = var.vm_name
  cpus   = var.vcpu
  memory = "${var.memory_mb}M"
  image  = var.image

  cloudinit_content = <<-EOF
    #cloud-config
    hostname: ${var.hostname}
    fqdn: ${var.hostname}
    manage_etc_hosts: true
    users:
      - name: root
        ssh_authorized_keys:
          - ${var.ssh_public_key}
          %{if var.jumpbox_ssh_public_key != ""}
          - ${var.jumpbox_ssh_public_key}
          %{endif}
    ssh_pwauth: true
    disable_root: false
    chpasswd:
      list: |
        root:debug123
      expire: false
  EOF
}
