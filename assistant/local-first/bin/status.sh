#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}═══ Smart AI Router Status ═══${NC}\n"

# ── Containers ──
echo -e "${CYAN}── Containers${NC}"
for container in devsecops-router devsecops-ollama; do
    state=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null || echo "not found")
    case "$state" in
        running) echo -e "  ${GREEN}$container${NC} : running" ;;
        *)       echo -e "  $container : ${state}" ;;
    esac
done

# ── Ollama cached models ──
echo -e "\n${CYAN}── Ollama — cached models${NC}"
docker exec devsecops-ollama ollama list 2>/dev/null || echo "  (ollama not running)"

# ── LiteLLM exposed models ──
echo -e "\n${CYAN}── LiteLLM — exposed models${NC}"
for i in $(seq 1 10); do
    MODELS=$(curl -sf http://127.0.0.1:4000/v1/models \
        -H "Authorization: Bearer local-routing-bypass" \
        2>/dev/null) && break
    [ "$i" -lt 10 ] && sleep 1
done
if [ -n "${MODELS:-}" ]; then
    echo "$MODELS" | python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', [])
for m in data:
    print(f'  {m[\"id\"]}')
"
else
    echo "  (litellm not reachable after 10s)"
fi

# ── Latency test ──
echo -e "\n${CYAN}── Latency test — local-14b${NC}"
start=$(date +%s%3N)
response=$(curl -sf http://127.0.0.1:4000/v1/chat/completions \
    -H "Authorization: Bearer local-routing-bypass" \
    -H "Content-Type: application/json" \
    -d '{"model":"local-14b","messages":[{"role":"user","content":"say ok"}],"max_tokens":4}' \
    2>/dev/null)
end=$(date +%s%3N)
elapsed=$((end - start))

if [ -n "$response" ]; then
    text=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'].strip())" 2>/dev/null)
    echo -e "  response : ${text:-<empty>}"
    echo -e "  latency  : ${elapsed}ms"

    if [ "$elapsed" -gt 3000 ]; then
        echo -e "  ${GREEN}verdict  : LOCAL (slow — CPU inference)${NC}"
    elif [ "$elapsed" -gt 800 ]; then
        echo -e "  ${YELLOW}verdict  : LOCAL (medium — likely GPU or small model)${NC}"
    else
        echo -e "  ${YELLOW}verdict  : REMOTE? (very fast — check logs)${NC}"
    fi
else
    echo -e "  (request failed — is the stack running?)"
fi

echo ""
