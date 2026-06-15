#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
VERBOSE=false

# Parse flags
for arg in "$@"; do
    case "$arg" in
        -v|--verbose) VERBOSE=true ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        # Expand ${VAR} references using already-exported values
        value=$(eval echo "$value" 2>/dev/null)
        export "$key"="$value"
    done < "$ENV_FILE"
    $VERBOSE && echo -e "${YELLOW}[*] Loaded $(grep -cv '^#' "$ENV_FILE") vars from .env${NC}"
else
    echo -e "${RED}[ERROR] .env file not found at $ENV_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Commencing Cryptographic API Verification Loop...${NC}\n"

# ==============================================================================
# 1. LITELLM GITHUB CONTAINER REGISTRY VERIFICATION
# ==============================================================================
echo -e "${YELLOW}[*] Querying ghcr.io for LiteLLM version: ${LITELLM_TAG}${NC}"

# Get anonymous pull token from ghcr.io (public repo, no GitHub auth needed)
LITELLM_TOKEN=$(curl -sL "https://ghcr.io/token?service=ghcr.io&scope=repository:berriai/litellm:pull" | jq -r '.token')

# Fetch the manifest list from ghcr.io and extract the amd64 image digest
WEB_LITELLM_SHA=$(curl -sL \
    -H "Authorization: Bearer ${LITELLM_TOKEN}" \
    -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json" \
    "https://ghcr.io/v2/berriai/litellm/manifests/${LITELLM_TAG}" \
    | jq -r '.manifests[] | select(.platform.architecture=="amd64") | .digest' \
    | cut -d':' -f2 || true)

# Query what the local docker client observes directly from the remote manifest index
CLI_LITELLM_SHA=$(docker manifest inspect "${LITELLM_REPO}:${LITELLM_TAG}" \
    | jq -r '.manifests[] | select(.platform.architecture=="amd64") | .digest' \
    | cut -d':' -f2 | head -n 1)

echo " -> ghcr.io API AMD64 SHA256   : $WEB_LITELLM_SHA"
echo " -> CLI Network Manifest SHA256: $CLI_LITELLM_SHA"

if [ -n "$WEB_LITELLM_SHA" ] && [ "$WEB_LITELLM_SHA" == "$CLI_LITELLM_SHA" ]; then
    echo -e "${GREEN}[PASS] LiteLLM image matches what is served by ghcr.io.${NC}\n"
else
    if [ "$CLI_LITELLM_SHA" == "$LITELLM_SHA" ]; then
        echo -e "${GREEN}[PASS] CLI manifest matches your local .env SHA fingerprint.${NC}\n"
    else
        echo -e "${RED}[WARNING] LiteLLM verification mismatch! Review upstream packaging actions.${NC}\n"
    fi
fi

# ==============================================================================
# 2. OLLAMA OFFICIAL DOCKER HUB API VERIFICATION
# ==============================================================================
echo -e "${YELLOW}[*] Querying Docker Hub V2 REST API for Ollama version: ${OLLAMA_TAG}${NC}"

# Query the Docker Hub metadata API endpoint.
# It isolates the specific image record matching your Intel processor architecture.
WEB_OLLAMA_SHA=$(curl -sL "${OLLAMA_API_URL}" \
    | jq -r '.images[] | select(.architecture=="amd64" and .os=="linux") | .digest' \
    | cut -d':' -f2)

# Query what the local docker client observes directly from the remote manifest index
CLI_OLLAMA_SHA=$(docker manifest inspect "${OLLAMA_REPO}:${OLLAMA_TAG}" \
    | jq -r '.manifests[] | select(.platform.architecture=="amd64" and .platform.os=="linux") | .digest' \
    | cut -d':' -f2)

echo " -> DockerHub API AMD64 SHA256: $WEB_OLLAMA_SHA"
echo " -> CLI Network Manifest SHA256: $CLI_OLLAMA_SHA"

if [ "$WEB_OLLAMA_SHA" == "$CLI_OLLAMA_SHA" ] && [ "$WEB_OLLAMA_SHA" == "$OLLAMA_SHA" ]; then
    echo -e "${GREEN}[PASS] Ollama image matches exactly across all API and local configuration profiles.${NC}\n"
else
    echo -e "${RED}[FAIL] Ollama provenance divergence detected! Check local mirror states.${NC}\n"
fi