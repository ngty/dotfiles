#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ENV_FILE="${HOME}/.config/codewhale/env"

# Capture a caller-provided version override (e.g. CODEWHALE_VERSION=0.9.7 ./bin/build.sh)
# before sourcing the env file, which would otherwise overwrite it.
VERSION_OVERRIDE="${CODEWHALE_VERSION:-}"

if [ -f "$ENV_FILE" ]; then
    . "$ENV_FILE"
fi

# A shell-provided override wins over the env file's pinned value.
VERSION="${VERSION_OVERRIDE:-${CODEWHALE_VERSION:-}}"
if [ -z "$VERSION" ]; then
    echo "Error: CODEWHALE_VERSION is not set (set it in ${ENV_FILE} or export it)" >&2
    exit 1
fi

IMAGE="local/codewhale:v${VERSION}-hardened"

if [ "${1:-}" = "-f" ]; then
    docker volume rm -f codewhale-home
fi
docker rmi "$IMAGE"
docker build --build-arg CODEWHALE_VERSION="$VERSION" -t "$IMAGE" "${SCRIPT_DIR}/../docker"
