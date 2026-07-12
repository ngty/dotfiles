#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
if [ "${1:-}" = "-f" ]; then
    docker volume rm -f codewhale-home
fi
docker rmi local/codewhale:v0.8.66-hardened 
docker build -t local/codewhale:v0.8.66-hardened "${SCRIPT_DIR}/../docker"
