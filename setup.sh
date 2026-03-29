#!/bin/bash
set -e

# Ensure snap binaries are in PATH
export PATH=$PATH:/snap/bin

# Install LXD if not present
if ! /snap/bin/lxc --version &>/dev/null 2>&1; then
  echo "LXD not found. Installing..."
  sudo snap install lxd
fi

# Add current user to lxd group if not already a member
if ! groups | grep -qw lxd; then
  echo "Adding $USER to the lxd group..."
  sudo usermod -aG lxd "$USER"
  echo "Re-running script under the lxd group..."
  exec sg lxd "$0" "$@"
fi

# Initialize LXD with defaults if no storage pools exist
if [ -z "$(sudo /snap/bin/lxc storage list --format csv 2>/dev/null)" ]; then
  echo "Initializing LXD (creating default storage pool)..."
  sudo /snap/bin/lxd init --auto
fi

# Create dedicated k8s bridge network if it doesn't exist
if ! /snap/bin/lxc network show lxdk8s &>/dev/null 2>&1; then
  echo "Creating lxdk8s bridge (10.142.131.1/24)..."
  /snap/bin/lxc network create lxdk8s \
    ipv4.address=10.142.131.1/24 \
    ipv4.nat=true \
    ipv6.address=none
fi

# Ensure /snap/bin is persisted in PATH for future shells
if ! grep -q '/snap/bin' ~/.bashrc; then
  echo 'export PATH=$PATH:/snap/bin' >> ~/.bashrc
  echo "Added /snap/bin to ~/.bashrc"
fi

echo "Done. You can now run: terraform -chdir=terraform apply"
