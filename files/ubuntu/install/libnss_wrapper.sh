#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install nss-wrapper to be able to execute image as non-root user"
apt-get update
apt-get install -y --no-install-recommends libnss-wrapper gettext
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

echo "add 'source generate_container_user' to .bashrc"

# have to be added to hold all env vars correctly
echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
