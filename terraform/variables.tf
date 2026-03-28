variable "multipass_image" {
  description = "Multipass image to use (e.g. 22.04)"
  type        = string
  default     = "22.04"
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
  }))
  default = {
    jumpbox = {
      vcpu     = 1
      memory   = 512
      hostname = "jumpbox"
    }
    server = {
      vcpu     = 1
      memory   = 2048
      hostname = "server"
    }
    node-0 = {
      vcpu     = 1
      memory   = 2048
      hostname = "node-0"
    }
    node-1 = {
      vcpu     = 1
      memory   = 2048
      hostname = "node-1"
    }
  }
}
