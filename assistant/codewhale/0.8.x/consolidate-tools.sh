#!/usr/bin/env bash
# ==============================================================================
# consolidate-tools.sh — Copy session tool scripts into docker/tools.d/
#
# Called by run.sh after the container exits. Copies each *.sh from
# the session directory into docker/tools.d/ so they're picked up at the
# next build, then removes the consumed session directory.
#
# Usage: consolidate-tools.sh <session_dir>
# ==============================================================================
set -euo pipefail

SESSION_DIR="${1:-}"
if [[ -z "$SESSION_DIR" ]]; then
    echo "Usage: consolidate-tools.sh <session_dir>" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TOOLS_D="${SCRIPT_DIR}/docker/tools.d"
SESSION_DIR_PATH="${SCRIPT_DIR}/sessions/${SESSION_DIR}"

mkdir -p "$TOOLS_D"

copied=0
for tools_file in "${SESSION_DIR_PATH}"/*.sh; do
    [[ -f "$tools_file" ]] || continue
    dest="${TOOLS_D}/$(basename "$tools_file")"
    cp "$tools_file" "$dest"
    echo "  → $(basename "$tools_file")"
    copied=$((copied + 1))
done

if [[ $copied -gt 0 ]]; then
    echo "consolidate-tools: copied ${copied} tool script(s) to docker/tools.d/"
fi

rm -rf "${SCRIPT_DIR}/sessions/${SESSION_DIR}"
