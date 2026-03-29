# Minimal-ish sizes for local smoke-testing
# (Debian cloud-init + SSH; adjust upward if you hit OOM)
ssh_public_key_path = "~/.ssh/id_rsa.pub"

vms = {
  jumpbox = {
    vcpu     = 1
    memory   = 512
    ip       = "192.168.122.2"
    mac      = "52:54:00:00:00:02"
    hostname = "jumpbox"
  }
  server = {
    vcpu     = 1
    memory   = 768
    ip       = "192.168.122.10"
    mac      = "52:54:00:00:00:10"
    hostname = "server"
  }
  node-0 = {
    vcpu     = 1
    memory   = 768
    ip       = "192.168.122.20"
    mac      = "52:54:00:00:00:20"
    hostname = "node-0"
  }
  node-1 = {
    vcpu     = 1
    memory   = 768
    ip       = "192.168.122.21"
    mac      = "52:54:00:00:00:21"
    hostname = "node-1"
  }
}
