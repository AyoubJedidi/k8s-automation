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

variable "image" {
  description = "Multipass image to use (e.g. 22.04)"
  type        = string
}
