#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$BIN_DIR/.." && pwd)"
cd "$PROJECT_DIR"

echo -e "${YELLOW}[*] Smart AI Router — Pre-flight Verification${NC}"
"$BIN_DIR/verify-image-sha.sh" "$@"

echo -e "\n${YELLOW}[*] Smart AI Router — Stack Startup${NC}"
"$BIN_DIR/startup-docker-compose.sh"
