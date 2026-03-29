#!/bin/bash
set -e

# Install LXD if not present
if ! command -v lxc &>/dev/null; then
  echo "LXD not found. Installing..."
  sudo snap install lxd
fi

# Initialize LXD with defaults if not already done
if ! lxc storage list &>/dev/null; then
  echo "Initializing LXD..."
  lxd init --auto
fi

echo "Done. You can now run: terraform -chdir=terraform apply"
