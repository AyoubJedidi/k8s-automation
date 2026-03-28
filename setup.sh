#!/bin/bash
set -e

# Check multipass is installed
if ! command -v multipass &>/dev/null; then
  echo "Multipass not found. Installing..."
  sudo snap install multipass
fi

# Authenticate user with multipass daemon (required once per machine)
# The passphrase is a temporary token — any value works, just used to register this user
PASSPHRASE="k8s-setup"
echo "Authenticating with Multipass daemon..."
sudo multipass set local.passphrase=$PASSPHRASE
multipass authenticate $PASSPHRASE

echo "Done. You can now run: terraform -chdir=terraform apply"
