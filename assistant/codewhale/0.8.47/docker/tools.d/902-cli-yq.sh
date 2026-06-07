#!/usr/bin/env bash
# Install yq v4.53.2 to /usr/local/bin/yq with digest verification.
# Source: https://github.com/mikefarah/yq/releases/tag/v4.53.2
set -euo pipefail

VERSION="4.53.2"
ARCH="linux_amd64"
BIN_NAME="yq_${ARCH}"
DOWNLOAD_URL="https://github.com/mikefarah/yq/releases/download/v${VERSION}/${BIN_NAME}"
EXPECTED_SHA256="d56bf5c6819e8e696340c312bd70f849dc1678a7cda9c2ad63eebd906371d56b"
TMPFILE="/tmp/yq-v${VERSION}"
INSTALL_PATH="/usr/local/bin/yq"

echo "==> Downloading yq v${VERSION} (${ARCH})..."
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
yq --version

rm -f "${TMPFILE}"
echo "==> Done."
