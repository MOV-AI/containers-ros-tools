#!/usr/bin/env bash
set -e

echo "Install TigerVNC server"
apt-get update
apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
