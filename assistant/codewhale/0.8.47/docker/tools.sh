#!/usr/bin/env bash
# ==============================================================================
# tools.sh — Dispatcher for tool installation scripts.
#
# Runs every *.sh script in tools.d/ in sorted order. Each script is a
# standalone, self-contained install snippet (apt, pip, npm, etc.).
#
# Build-time:  sourced by docker/Dockerfile (RUN bash /tmp/tools.sh)
# Session-end: consolidate-tools.sh copies new tool scripts into tools.d/
#              so they're picked up on the next build.
# ==============================================================================
set -euo pipefail

TOOLS_DIR="$(dirname "$0")/tools.d"

if [ -d "$TOOLS_DIR" ] && [ -n "$(ls "$TOOLS_DIR"/*.sh 2>/dev/null)" ]; then
    for script in $(ls "$TOOLS_DIR"/*.sh 2>/dev/null | sort); do
        echo "=== $(basename "$script") ==="
        bash "$script"
    done
else
    echo "tools.sh: no scripts found in $TOOLS_DIR"
fi
