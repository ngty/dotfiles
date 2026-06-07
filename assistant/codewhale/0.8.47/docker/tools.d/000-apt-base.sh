#!/usr/bin/env bash
# Base system packages required by the hardened container.
set -euo pipefail
apt-get update
apt-get install -y gosu iptables passwd curl sudo ca-certificates libicu72
apt-get clean
rm -rf /var/lib/apt/lists/*
