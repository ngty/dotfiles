#!/usr/bin/env bash
# Install PowerShell 7.6.2 for Debian 12 (bookworm) x86_64
#   - downloads tar.gz with SHA256 digest verification
#   - extracts to /opt/microsoft/powershell/7, symlinks /usr/local/bin/pwsh
set -euo pipefail

PW_VERSION="7.6.2"

ARCHIVE="powershell-${PW_VERSION}-linux-x64.tar.gz"
DOWNLOAD_URL="https://github.com/PowerShell/PowerShell/releases/download/v${PW_VERSION}/${ARCHIVE}"
EXPECTED_SHA256="6cbcfbf20e376aa62ffd91c973493c41a7a52ddfd5a5db3ff9bc12f0d0fe9292"

INSTALL_DIR="/opt/microsoft/powershell/${PW_VERSION}"
BIN_PATH="/usr/local/bin/pwsh"
TMPFILE="/tmp/powershell-${PW_VERSION}.tar.gz"

# ── already installed? ────────────────────────────────────────────────────────
if command -v pwsh &>/dev/null; then
    echo "==> pwsh already installed ($(pwsh --version))"
    exit 0
fi

# ── download ──────────────────────────────────────────────────────────────────
echo "==> Downloading PowerShell v${PW_VERSION}..."
curl -fsSL --retry 3 --retry-delay 2 -o "${TMPFILE}" "${DOWNLOAD_URL}"

# ── digest verification ───────────────────────────────────────────────────────
echo "==> Verifying SHA256 digest..."
COMPUTED=$(sha256sum "${TMPFILE}" | awk '{print $1}')
if [ "${COMPUTED}" != "${EXPECTED_SHA256}" ]; then
    echo "ERROR: SHA256 mismatch" >&2
    echo "  expected: ${EXPECTED_SHA256}" >&2
    echo "  got:      ${COMPUTED}" >&2
    rm -f "${TMPFILE}"
    exit 1
fi
echo "  digest OK: ${COMPUTED}"

# ── extract ───────────────────────────────────────────────────────────────────
echo "==> Extracting to ${INSTALL_DIR}..."
sudo mkdir -p "${INSTALL_DIR}"
sudo tar xzf "${TMPFILE}" -C "${INSTALL_DIR}"

# ── symlink ───────────────────────────────────────────────────────────────────
echo "==> Symlinking ${BIN_PATH} -> ${INSTALL_DIR}/pwsh..."
sudo ln -sf "${INSTALL_DIR}/pwsh" "${BIN_PATH}"

# ── verify ────────────────────────────────────────────────────────────────────
echo "==> Verifying install..."
pwsh --version

rm -f "${TMPFILE}"
echo "==> Done. pwsh ${PW_VERSION} installed."
