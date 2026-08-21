# AGENTS.md — Docker Hardened AI Agent Workspace

## Project Overview

This is a hardened Docker workspace for running AI coding agents inside a security-constrained container. It builds on the CodeWhale base image and adds network isolation, user remapping, and sandbox enforcement at runtime.

- **Base image**: `ghcr.io/hmbown/codewhale:v${CODEWHALE_VERSION}` (version pinned in `~/.config/codewhale/env`)
- **Local tag**: `local/codewhale:v${CODEWHALE_VERSION}-hardened`
- **Entrypoint**: `docker/entrypoint.sh` — runs before any user command, applies hardening
- **Default command**: launches the agent terminal UI
- **Agent user**: `codewhale` (inside the container)

## Key Files

| File | Purpose |
|------|---------|
| `bin/build.sh` | Build the Docker image — removes old image/volume, then builds from `docker/` |
| `bin/run.sh` | Launch the container — loads credentials, mounts workspace, applies network caps |
| `bin/consolidate-tools.sh` | Copies session tool scripts into `docker/tools.d/` after container exits |
| `scripts/deepseek` | Wrapper: sets `CODEWHALE_PROVIDER=deepseek` and launches via `bin/run.sh` |
| `scripts/qwen` | Wrapper: sets `CODEWHALE_PROVIDER=openai` and launches via `bin/run.sh` |
| `docker/Dockerfile` | Image definition — installs `gosu`, `iptables`, `passwd`, `curl`; copies entrypoint |
| `docker/tools.sh` | Tool dependency dispatcher — runs all scripts in `docker/tools.d/` |
| `docker/entrypoint.sh` | Runtime hardening — iptables blocks, UID remap, permission fixes, command routing |
| `.gitignore` | Ignores `.codewhale/` state directory |
| `env.sample` | Environment template — copy to `~/.config/codewhale/env`; pins `CODEWHALE_VERSION` and API keys |
| `UPDATE.md` | Upgrade playbook — version gates, rebuild/smoke-test, rollback; follow before bumping `CODEWHALE_VERSION` |

## Build Commands

```sh
# Full rebuild (cleans previous image and volume first)
./bin/build.sh

# Or manually (version read from ~/.config/codewhale/env):
. ~/.config/codewhale/env
docker build --build-arg CODEWHALE_VERSION="$CODEWHALE_VERSION" \
  -t "local/codewhale:v${CODEWHALE_VERSION}-hardened" docker
```

## Run Commands

```sh
# Launch the agent session (requires API credentials in ~/.config/codewhale/env)
./bin/run.sh

# Drop into a shell inside the container
./bin/run.sh -- bash

# Pass arguments through to the agent CLI
./bin/run.sh -- codewhale --version

# Launch in a specific workspace directory
./bin/run.sh /path/to/project

# Shell in a specific workspace directory
./bin/run.sh /path/to/project -- bash

# Provider wrappers — same args as run.sh, auto-set via CODEWHALE_PROVIDER
./scripts/deepseek                        # Launch with DeepSeek
./scripts/deepseek /path/to/project       # DeepSeek in specific workspace
./scripts/qwen                            # Launch with Qwen (DashScope)
./scripts/qwen /path/to/project           # Qwen in specific workspace
```

## Architecture Notes

- The entrypoint script runs as **root** (required for `iptables` and `usermod`), then drops to the `codewhale` user via `gosu` before executing the target command.
- Host UID/GID is read from `/workspace` via `stat` and applied to the container's `codewhale` user — this ensures files written inside the container match host file ownership.
- A Docker volume (`codewhale-home`) persists agent state (conversations, configuration, notes) across container restarts.
- Network hardening blocks all RFC 1918 private address ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) plus the AWS metadata endpoint (169.254.169.254) via `iptables`.
- DNS is pinned to public resolvers (1.1.1.1, 8.8.8.8) to prevent local resolver leaks.
- The agent runs under a strict execution policy (`CODEWHALE_EXECPOLICY=strict`).

## Constraints

When editing files in this project, observe the following rules:

- **Do not remove or weaken** the iptables rules in `docker/entrypoint.sh` without explicit user approval. These are security boundaries.
- **Do not change** the `CODEWHALE_EXECPOLICY` environment variable in `bin/run.sh`.
- **Do not modify** the UID remapping logic in `entrypoint.sh` — it exists to prevent permission drift on host files.
- **Shell scripts** use `set -euo pipefail` (bash) or `set -eu` (POSIX sh). Maintain this strictness.
- **The `.codewhale/` directory** is git-ignored. Do not commit agent state files.

## File-Specific Guidelines

- **`docker/Dockerfile`**: Tool installation is delegated to `tools.sh` (dispatches to `tools.d/*.sh`, copied as one layer, then removed). To add packages, add a standalone script to `docker/tools.d/` — reviewable before rebuild.
- **`docker/tools.sh`**: Dispatcher that runs every `*.sh` in `docker/tools.d/` in sorted order. Not mounted into the container — only consumed by the Dockerfile at build time.
- **`sessions/`**: Per-session tracking directories. Each session gets a `session-<DATE>-<ID>` directory. **When the agent installs a tool during a session, it must create the next available `tool-NNN.sh` file inside `$CODEWHALE_TOOLS_DIR`** — 1st tool goes to `tool-001.sh`, 2nd to `tool-002.sh`, and so on. Each file is a standalone shell script (shebang, `set -eu`, install commands) that can run independently. On session exit, `consolidate-tools.sh` copies all `tool-*.sh` into `docker/tools.d/` for the next build and removes the consumed session directory. Avoids write conflicts across concurrent sessions.
- **`docker/entrypoint.sh`**: this is a POSIX `#!/bin/sh` script, not bash. Do not use bashisms (`[[`, `==`, arrays, `source`, etc.).
- **`bin/run.sh`**: this is bash with `set -euo pipefail`. The `TARGET_DIR` is derived via `pwd -P` (physical path, no symlinks) — do not replace with `$(pwd)`.
- **`bin/build.sh`**: intentionally nukes the old volume and image before rebuilding. If you need to preserve state between builds, modify this behavior with user approval.
- **`UPDATE.md`**: the version-upgrade playbook. When bumping `CODEWHALE_VERSION`, follow it (vulnerability + 7-day age gates, env edit, rebuild, smoke-test, rollback) instead of making ad-hoc version edits.
- **`scripts/deepseek` / `scripts/qwen`**: thin wrappers around `bin/run.sh` that set `CODEWHALE_PROVIDER` to `deepseek` or `openai` and then exec `bin/run.sh`. They accept the same arguments as `bin/run.sh`. `bin/run.sh` forwards `CODEWHALE_PROVIDER` into the container via `docker run -e`. Keep them minimal.