#!/usr/bin/env bash
# Python 3 runtime and pip.
set -euo pipefail
apt-get update
apt-get install -y python3 python3-pip
apt-get clean
rm -rf /var/lib/apt/lists/*
