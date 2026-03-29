variable "lxd_image" {
  description = "LXD image to use (e.g. ubuntu:22.04)"
  type        = string
  default     = "ubuntu:22.04"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vms" {
  description = "VM definitions"
  type = map(object({
    vcpu     = number
    memory   = number
    hostname = string
    ip       = string
  }))
  default = {
    jumpbox = {
      vcpu     = 1
      memory   = 512
      hostname = "jumpbox"
      ip       = "10.142.131.10"
    }
    server = {
      vcpu     = 1
      memory   = 2048
      hostname = "server"
      ip       = "10.142.131.11"
    }
    node-0 = {
      vcpu     = 1
      memory   = 2048
      hostname = "node-0"
      ip       = "10.142.131.12"
    }
    node-1 = {
      vcpu     = 1
      memory   = 2048
      hostname = "node-1"
      ip       = "10.142.131.13"
    }
  }
}
