terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "lxd" {}

# ── Jumpbox SSH keypair ────────────────────────────────────────────────────────
resource "tls_private_key" "jumpbox" {
  algorithm = "ED25519"
}

# ── VMs ───────────────────────────────────────────────────────────────────────
module "vms" {
  for_each = var.vms
  source   = "./modules/vm"

  vm_name        = each.key
  vcpu           = each.value.vcpu
  memory_mb      = each.value.memory
  hostname       = each.value.hostname
  ip             = each.value.ip
  image          = var.lxd_image
  ssh_public_key = trimspace(file(var.ssh_public_key_path))

  jumpbox_ssh_public_key  = each.key != "jumpbox" ? trimspace(tls_private_key.jumpbox.public_key_openssh) : ""
  jumpbox_ssh_private_key = each.key == "jumpbox" ? tls_private_key.jumpbox.private_key_openssh : ""
}

# ── Generate hosts file for jumpbox (/etc/hosts) ──────────────────────────────
resource "local_file" "hosts" {
  filename = "${path.module}/hosts"
  content = templatefile("${path.module}/templates/hosts.tpl", {
    vms = { for k, v in module.vms : k => {
      ip       = v.vm_ip,
      hostname = var.vms[k].hostname
    } }
  })
}

# ── Generate Ansible inventory ─────────────────────────────────────────────────
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    vms = { for k, v in module.vms : k => {
      ip       = v.vm_ip,
      hostname = var.vms[k].hostname
    } }
  })
}

# ── Wait for SSH to be ready on all VMs ───────────────────────────────────────
resource "null_resource" "wait_for_ssh" {
  for_each = var.vms

  depends_on = [module.vms]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for SSH on ${each.value.ip}..."
      until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes root@${each.value.ip} echo ok 2>/dev/null; do
        sleep 3
      done
      echo "${each.key} (${each.value.ip}) is ready"
    EOT
  }
}

# ── Save jumpbox private key locally ──────────────────────────────────────────
resource "local_sensitive_file" "jumpbox_private_key" {
  filename        = "${path.module}/jumpbox_id_ed25519"
  content         = tls_private_key.jumpbox.private_key_openssh
  file_permission = "0600"
}
