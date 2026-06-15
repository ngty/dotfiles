#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define color outputs for terminal logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[*] Starting Local AI Smart Router Platform Initialization...${NC}"

# 1. Ensure absolute path persistence — project root is one level above bin/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# 2. Check for required configuration files
if [ ! -f ".env" ]; then
    echo -e "${RED}[ERROR] Configuration file '.env' not found in $PROJECT_DIR.${NC}"
    echo -e "${YELLOW}[HINT] Please create a '.env' file matching your secrets template before executing.${NC}"
    exit 1
fi

if [ ! -f "docker-compose.yml" ] || [ ! -f "config/litellm.yaml" ]; then
    echo -e "${RED}[ERROR] Core YAML manifests (docker-compose.yml or config/litellm.yaml) are missing.${NC}"
    exit 1
fi

# 3. Securely handle directory creation for Copilot OAuth Token storage
if [ ! -d "copilot_tokens" ]; then
    echo -e "${YELLOW}[*] Creating localized 'copilot_tokens' storage directory...${NC}"
    mkdir -p copilot_tokens
    # Restrict read/write privileges strictly to your user profile
    chmod 700 copilot_tokens
fi

# 4. Perform DevSecOps Pre-Flight Verification Linting
echo -e "${YELLOW}[*] Linting variable interpolation schemas...${NC}"
docker compose config > /dev/null

# 5. Bootstrapping Container Engine Stack
echo -e "${GREEN}[+] Compilation successful. Launching immutable container layers...${NC}"
docker compose up -d

# 6. Post-deployment runtime checks
echo -e "${YELLOW}[*] Verifying container runtimes are active...${NC}"
sleep 2

if [ "$(docker inspect -f '{{.State.Running}}' devsecops-router)" = "true" ] && \
   [ "$(docker inspect -f '{{.State.Running}}' devsecops-ollama)" = "true" ]; then
    echo -e "${GREEN}[SUCCESS] Local routing stack initialized and bound to 127.0.0.1:4000${NC}"

    # 7. Pull local Ollama models declared in litellm-config.yaml
    "$SCRIPT_DIR/pull-local-models.sh"
    echo -e "\nTo complete GitHub Copilot setup, run:"
    echo -e "  ${YELLOW}docker logs devsecops-router | grep \"github.com/login/device\"${NC}"
else
    echo -e "${RED}[ERROR] Containers failed to achieve steady runtime state. Check 'docker compose logs'.${NC}"
    exit 1
fi
