#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}[*] Smart AI Router — Restart${NC}"

"$BIN_DIR/stop.sh"
echo ""
"$BIN_DIR/start.sh" "$@"
