#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/litellm.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[ERROR] config/litellm.yaml not found at $CONFIG_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Extracting local Ollama models from litellm-config.yaml...${NC}"

MODELS=$(grep 'model: openai/' "$CONFIG_FILE" \
    | grep -v '^[[:space:]]*#' \
    | sed 's/.*openai\///')

if [ -z "$MODELS" ]; then
    echo -e "${YELLOW}[*] No local models found (all openai/ entries are commented out).${NC}"
    exit 0
fi

echo -e "${YELLOW}[*] Pulling model weights into Ollama...${NC}"
while read -r model; do
    [ -z "$model" ] && continue
    echo -e "  -> $model"
    docker exec devsecops-ollama ollama pull "$model"
done <<< "$MODELS"

echo -e "${GREEN}[READY] Local models cached and available${NC}"
