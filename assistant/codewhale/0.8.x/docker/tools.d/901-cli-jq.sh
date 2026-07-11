#!/usr/bin/env bash
# Install jq 1.8.1 to /usr/local/bin/jq with digest verification.
# Source: https://github.com/jqlang/jq/releases/tag/jq-1.8.1
set -euo pipefail

VERSION="1.8.1"
ARCH="linux-amd64"
BIN_NAME="jq-${ARCH}"
DOWNLOAD_URL="https://github.com/jqlang/jq/releases/download/jq-${VERSION}/${BIN_NAME}"
EXPECTED_SHA256="020468de7539ce70ef1bceaf7cde2e8c4f2ca6c3afb84642aabc5c97d9fc2a0d"
TMPFILE="/tmp/jq-${VERSION}"
INSTALL_PATH="/usr/local/bin/jq"

echo "==> Downloading jq ${VERSION} (${ARCH})..."
curl -sSLo "${TMPFILE}" "${DOWNLOAD_URL}"

echo "==> Verifying SHA256 digest..."
COMPUTED=$(sha256sum "${TMPFILE}" | awk '{print $1}')
if [ "${COMPUTED}" != "${EXPECTED_SHA256}" ]; then
    echo "ERROR: digest mismatch"
    echo "  expected: ${EXPECTED_SHA256}"
    echo "  got:      ${COMPUTED}"
    rm -f "${TMPFILE}"
    exit 1
fi
echo "  digest OK: ${COMPUTED}"

echo "==> Installing to ${INSTALL_PATH}..."
sudo install -m 755 "${TMPFILE}" "${INSTALL_PATH}"

echo "==> Verifying install..."
jq --version

rm -f "${TMPFILE}"
echo "==> Done."
