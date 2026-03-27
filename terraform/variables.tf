variable "libvirt_uri" {
  description = "Libvirt connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "pool_name" {
  description = "Libvirt storage pool for VM disks (must be under /var/lib/libvirt/images/ for AppArmor)"
  type        = string
  default     = "k8s-lab"
}

# NOTE: the k8s-lab pool must point to /var/lib/libvirt/images/k8s-lab
# to avoid AppArmor permission denials on QEMU. Run once to create it:
#   virsh pool-define-as k8s-lab dir --target /var/lib/libvirt/images/k8s-lab
#   virsh pool-autostart k8s-lab && virsh pool-start k8s-lab

variable "network_name" {
  description = "Libvirt network to attach VMs to"
  type        = string
  default     = "default"
}

variable "network_gateway" {
  description = "Gateway IP of the libvirt network"
  type        = string
  default     = "192.168.122.1"
}

variable "network_prefix" {
  description = "CIDR prefix length of the libvirt network"
  type        = number
  default     = 24
}

variable "debian_image_url" {
  description = "URL or local path to Debian 12 cloud image"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# ip: static IP configured inside the VM via cloud-init (netplan)
# mac: fixed MAC so the DHCP server also hands out the same IP — belt-and-suspenders
variable "vms" {
  description = "VM definitions"
  type = map(object({
    vcpu     = number
    memory   = number
    ip       = string
    mac      = string
    hostname = string
  }))
  default = {
    jumpbox = {
      vcpu     = 1
      memory   = 512
      ip       = "192.168.122.2"
      mac      = "52:54:00:00:00:02"
      hostname = "jumpbox"
    }
    server = {
      vcpu     = 1
      memory   = 2048
      ip       = "192.168.122.10"
      mac      = "52:54:00:00:00:10"
      hostname = "server"
    }
    node-0 = {
      vcpu     = 1
      memory   = 2048
      ip       = "192.168.122.20"
      mac      = "52:54:00:00:00:20"
      hostname = "node-0"
    }
    node-1 = {
      vcpu     = 1
      memory   = 2048
      ip       = "192.168.122.21"
      mac      = "52:54:00:00:00:21"
      hostname = "node-1"
    }
  }
}
