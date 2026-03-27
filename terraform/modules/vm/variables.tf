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

variable "disk_size" {
  description = "Disk size in bytes"
  type        = number
  default     = 10737418240 # 10GB
}

variable "base_image_path" {
  description = "Path of the base volume on host (used as backing store)"
  type        = string
}

variable "pool_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "mac_address" {
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

variable "hostname" {
  type = string
}

variable "static_ip" {
  description = "Static IP assigned via cloud-init netplan"
  type        = string
}

variable "network_gateway" {
  type    = string
  default = "192.168.122.1"
}

variable "network_prefix" {
  type    = number
  default = 24
}
