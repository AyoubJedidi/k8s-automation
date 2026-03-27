terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

# COW disk using base image as backing store
resource "libvirt_volume" "disk" {
  name = "${var.vm_name}.qcow2"
  pool = var.pool_name

  backing_store = {
    path = var.base_image_path
    format = {
      type = "qcow2"
    }
  }

  capacity      = var.disk_size
  capacity_unit = "bytes"

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Cloud-init ISO
resource "libvirt_cloudinit_disk" "init" {
  name      = "${var.vm_name}-init.iso"
  meta_data = <<-EOF
    instance-id: ${var.vm_name}
    local-hostname: ${var.hostname}
  EOF

  user_data = <<-EOF
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
    packages:
      - qemu-guest-agent
    runcmd:
      - systemctl enable --now qemu-guest-agent
  EOF

  network_config = <<-EOF
    version: 2
    ethernets:
      enp0s2:
        dhcp4: true
      enp0s3:
        dhcp4: true
      enp1s0:
        dhcp4: true
      eth0:
        dhcp4: true
  EOF
}

# VM domain
resource "libvirt_domain" "vm" {
  name        = var.vm_name
  type        = "kvm"
  vcpu        = var.vcpu
  memory      = var.memory_mb
  memory_unit = "MiB"
  running     = true
  autostart   = true

  lifecycle {
    ignore_changes = [id]
  }

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type = "hvm"
  }

  devices = {
    disks = [
      {
        device = "disk"
        source = {
          volume = {
            pool   = var.pool_name
            volume = libvirt_volume.disk.name
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "qcow2"
        }
      },
      {
        device = "cdrom"
        source = {
          file = {
            file = libvirt_cloudinit_disk.init.path
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        read_only = true
      }
    ]

    interfaces = [
      {
        source = {
          network = {
            network = var.network_name
          }
        }
        mac = {
          address = var.mac_address
        }
        model = {
          type = "virtio"
        }
      }
    ]

    consoles = [
      {
        target = {
          type = "serial"
          port = 0
        }
      }
    ]
  }
}
