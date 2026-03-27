terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# ── Jumpbox SSH keypair ────────────────────────────────────────────────────────
resource "tls_private_key" "jumpbox" {
  algorithm = "ED25519"
}

# ── Storage pool ──────────────────────────────────────────────────────────────
resource "null_resource" "pool_start" {
  provisioner "local-exec" {
    command = "virsh pool-start ${var.pool_name} 2>/dev/null || true"
  }
}

# ── Base Debian 12 cloud image ────────────────────────────────────────────────
resource "libvirt_volume" "debian_base" {
  name   = "debian-12-base.qcow2"
  pool   = var.pool_name
  create = {
    content = {
      url = var.debian_image_url
    }
  }
  target = {
    format = {
      type = "qcow2"
    }
  }

  depends_on = [null_resource.pool_start]
}

# ── DHCP reservations ─────────────────────────────────────────────────────────
# Each VM's MAC always gets the same IP from libvirt's dnsmasq.
# This makes IPs deterministic without needing static IP inside the guest.
resource "null_resource" "dhcp_reservations" {
  for_each = var.vms

  triggers = {
    mac      = each.value.mac
    ip       = each.value.ip
    hostname = each.value.hostname
    network  = var.network_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      virsh net-update ${var.network_name} add ip-dhcp-host \
        "<host mac='${each.value.mac}' name='${each.value.hostname}' ip='${each.value.ip}'/>" \
        --live --config 2>/dev/null || \
      virsh net-update ${var.network_name} modify ip-dhcp-host \
        "<host mac='${each.value.mac}' name='${each.value.hostname}' ip='${each.value.ip}'/>" \
        --live --config 2>/dev/null || true
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      virsh net-update ${self.triggers.network} delete ip-dhcp-host \
        "<host mac='${self.triggers.mac}' name='${self.triggers.hostname}' ip='${self.triggers.ip}'/>" \
        --live --config 2>/dev/null || true
    EOT
  }
}

# ── VMs ───────────────────────────────────────────────────────────────────────
module "vms" {
  for_each = var.vms
  source   = "./modules/vm"

  vm_name        = each.key
  vcpu           = each.value.vcpu
  memory_mb      = each.value.memory
  mac_address    = each.value.mac
  hostname       = each.value.hostname
  static_ip      = each.value.ip
  network_gateway = var.network_gateway
  network_prefix  = var.network_prefix
  base_image_path = libvirt_volume.debian_base.path
  pool_name       = var.pool_name
  network_name    = var.network_name
  ssh_public_key  = trimspace(file(var.ssh_public_key_path))

  jumpbox_ssh_public_key = each.key != "jumpbox" ? trimspace(tls_private_key.jumpbox.public_key_openssh) : ""

  depends_on = [null_resource.dhcp_reservations]
}

# ── Generate hosts file for jumpbox (/etc/hosts) ──────────────────────────────
resource "local_file" "hosts" {
  filename = "${path.module}/hosts"
  content  = templatefile("${path.module}/templates/hosts.tpl", { vms = var.vms })
}

# ── Generate Ansible inventory ─────────────────────────────────────────────────
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content  = templatefile("${path.module}/templates/inventory.tpl", { vms = var.vms })
}

# ── Save jumpbox private key locally ──────────────────────────────────────────
resource "local_sensitive_file" "jumpbox_private_key" {
  filename        = "${path.module}/jumpbox_id_ed25519"
  content         = tls_private_key.jumpbox.private_key_openssh
  file_permission = "0600"
}
