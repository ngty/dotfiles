#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ENV_FILE="${HOME}/.config/codewhale/env"

# Load the env file to obtain the pinned CodeWhale version (single source of truth).
if [ -f "$ENV_FILE" ]; then
    . "$ENV_FILE"
fi

VERSION="${CODEWHALE_VERSION:-}"
if [ -z "$VERSION" ]; then
    echo "Error: CODEWHALE_VERSION is not set in ${ENV_FILE}" >&2
    exit 1
fi

IMAGE="local/codewhale:v${VERSION}-hardened"

if [ "${1:-}" = "-f" ]; then
    docker volume rm -f codewhale-home
fi
docker rmi "$IMAGE"
docker build --build-arg CODEWHALE_VERSION="$VERSION" -t "$IMAGE" "${SCRIPT_DIR}/../docker"
