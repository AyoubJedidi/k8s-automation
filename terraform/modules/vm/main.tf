terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.10"
    }
  }
}

resource "lxd_instance" "vm" {
  name    = var.vm_name
  image   = var.image
  type    = "virtual-machine"
  start_on_create = true
  wait_for_network = true

  config = {
    "limits.cpu"    = tostring(var.vcpu)
    "limits.memory" = "${var.memory_mb}MiB"
    "user.user-data" = <<-EOF
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
      write_files:
        - path: /etc/netplan/99-static.yaml
          content: |
            network:
              version: 2
              ethernets:
                enp5s0:
                  addresses:
                    - ${var.ip}/24
                  routes:
                    - to: default
                      via: ${var.gateway}
                  nameservers:
                    addresses:
                      - ${var.gateway}
      runcmd:
        - netplan apply
    EOF
  }
}
