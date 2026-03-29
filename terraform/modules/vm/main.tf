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

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network
    }
  }

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
        %{if var.jumpbox_ssh_private_key != ""}
        - path: /root/.ssh/id_ed25519
          permissions: '0600'
          encoding: b64
          content: ${base64encode(var.jumpbox_ssh_private_key)}
        %{endif}
        - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
          content: |
            network: {config: disabled}
        - path: /etc/netplan/99-static.yaml
          content: |
            network:
              version: 2
              ethernets:
                id0:
                  match:
                    name: "en*"
                  dhcp4: no
                  addresses:
                    - ${var.ip}/24
                  routes:
                    - to: default
                      via: ${var.gateway}
                  nameservers:
                    addresses:
                      - ${var.gateway}
      runcmd:
        - rm -f /etc/netplan/50-cloud-init.yaml
        - netplan apply
        - echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/50-cloud-init.conf
        - systemctl restart ssh
    EOF
  }
}
