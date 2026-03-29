variable "vm_name" {
  type = string
}

variable "vcpu" {
  type    = number
  default = 1
}

variable "memory_mb" {
  type    = number
  default = 512
}

variable "hostname" {
  type = string
}

variable "ssh_public_key" {
  description = "Operator SSH public key"
  type        = string
}

variable "jumpbox_ssh_public_key" {
  description = "Jumpbox SSH public key (added to non-jumpbox VMs)"
  type        = string
  default     = ""
}

variable "jumpbox_ssh_private_key" {
  description = "Jumpbox SSH private key (written to jumpbox only)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "image" {
  description = "LXD image to use (e.g. ubuntu:22.04)"
  type        = string
}

variable "ip" {
  description = "Static IP address for the VM (e.g. 10.142.131.10)"
  type        = string
}

variable "gateway" {
  description = "Gateway IP (lxdbr0 address)"
  type        = string
  default     = "10.142.131.1"
}

variable "storage_pool" {
  description = "LXD storage pool to use for the root disk"
  type        = string
  default     = "default"
}

variable "network" {
  description = "LXD network bridge to attach the VM to"
  type        = string
  default     = "lxdk8s"
}
