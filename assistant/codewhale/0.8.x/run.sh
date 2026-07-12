#!/usr/bin/env bash
# ==============================================================================
# CodeWhale (v0.8.66) Consolidated Hardened Workspace Runner
# Loads environment keys, mounts physical PWD, and applies network drop logic.
# ==============================================================================
set -euo pipefail

# 1. Load Local Credentials
ENV_FILE="${HOME}/.config/codewhale/env"
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
else
    echo "❌ Error: config file not found at ${ENV_FILE}" >&2
    exit 1
fi

if [[ -z "${DEEPSEEK_API_KEY:-}" ]]; then
    echo "❌ Error: DEEPSEEK_API_KEY is not populated inside ${ENV_FILE}" >&2
    exit 1
fi

# 2. Resolve project root (follows symlinks, e.g. ~/bin/deepseek → run.sh)
PROJECT_ROOT="$(dirname "$(readlink -f "$0")")"

# 2a. Create per-session tools tracking directory (tools files created on-demand by the agent)
SESSION_DIR="session-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "${PROJECT_ROOT}/sessions/${SESSION_DIR}"

# 3. Rename tmux window and restore on exit
if [[ -n "${TMUX:-}" ]]; then
    original_window=$(tmux display-message -p '#W')
    tmux rename-window "DSeek"
    cleanup() {
        tmux rename-window "$original_window"
        "${PROJECT_ROOT}/consolidate-tools.sh" "${SESSION_DIR}" || true
    }
    trap cleanup EXIT
fi

# 4. Parse workspace path and container command
#    -- separates workspace (before) from command (after).
#    run.sh                          → PWD, default command
#    run.sh -- bash                  → PWD, bash
#    run.sh /some/project            → /some/project, default command
#    run.sh /some/project -- bash    → /some/project, bash
workspace_args=()
cmd_args=()
split=false
for arg in "$@"; do
    if [[ "$split" == false && "$arg" == "--" ]]; then
        split=true
        continue
    fi
    if [[ "$split" == false ]]; then
        workspace_args+=("$arg")
    else
        cmd_args+=("$arg")
    fi
done

if [[ ${#workspace_args[@]} -gt 0 ]]; then
    TARGET_DIR=$(cd "${workspace_args[0]}" && pwd -P)
else
    TARGET_DIR=$(pwd -P)
fi
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "❌ Error: Could not reliably evaluate working directory." >&2
    exit 1
fi

# 5. Maintain State Infrastructure Volume
VOLUME_NAME="codewhale-home"
docker volume create "$VOLUME_NAME" >/dev/null

# 6. Fire the Containerized Terminal TUI Session
# --cap-add=NET_ADMIN grants permission to drop internal private subnet routing routes
docker run --rm -it \
  --name "codewhale-session-$(date +%s)" \
  --network bridge \
  --cap-add=NET_ADMIN \
  -e DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY" \
  -e OPENAI_API_KEY="${DASHSCOPE_API_KEY:-}" \
  -e OPENAI_BASE_URL="${DASHSCOPE_BASE_URL:-}" \
  -e CODEWHALE_PROVIDER="${CODEWHALE_PROVIDER:-}" \
  -e DEEPSEEK_SANDBOX_MODE="workspace-write" \
  -e CODEWHALE_EXECPOLICY="strict" \
  --dns 1.1.1.1 \
  --dns 8.8.8.8 \
  -v "${VOLUME_NAME}:/home/codewhale/.codewhale" \
  -v "${TARGET_DIR}:/workspace" \
  -e CODEWHALE_TOOLS_DIR="/tmp/${SESSION_DIR}" \
  -v "${PROJECT_ROOT}/sessions/${SESSION_DIR}:/tmp/${SESSION_DIR}" \
  -w /workspace \
  local/codewhale:v0.8.66-hardened "${cmd_args[@]}"