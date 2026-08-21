# CodeWhale Hardened Workspace

Hardened Docker workspace for [CodeWhale](https://github.com/hmbown/codewhale) — a containerized AI coding agent with network isolation, user remapping, and terminal TUI execution. The CodeWhale version is pinned via `CODEWHALE_VERSION` in `~/.config/codewhale/env`.

## Prerequisites

- Docker (with BuildKit support)
- A `~/.config/codewhale/env` file with API credentials and the pinned CodeWhale version. Start from the template:

  ```sh
  mkdir -p ~/.config/codewhale
  cp env.sample ~/.config/codewhale/env
  ```

  Then edit `~/.config/codewhale/env` to fill in real values. The template:

  ```sh
  # CodeWhale version to build and run — single source of truth
  export CODEWHALE_VERSION="0.8.66"

  # DeepSeek
  export DEEPSEEK_API_KEY="sk-..."
  # export DEEPSEEK_OPENAI_URL=...       # (builtin)
  # export DEEPSEEK_ANTHROPIC_URL=...    # (builtin)

  # DashScope (Qwen)
  export DASHSCOPE_API_KEY="sk-..."
  export DASHSCOPE_OPENAI_URL="https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
  export DASHSCOPE_ANTHROPIC_URL="https://dashscope-intl.aliyuncs.com/apps/anthropic"
  ```

## Quick Start

```sh
# Build the hardened image
./bin/build.sh

# Launch with DeepSeek (default)
./bin/run.sh

# Or launch with a specific provider
./scripts/deepseek          # DeepSeek
./scripts/qwen              # Qwen via DashScope
```

> Tip: symlink `scripts/qwen` and `scripts/deepseek` into your `PATH` (e.g. `~/bin/`)
> to launch with `qwen` / `deepseek` from anywhere.

## Build

`bin/build.sh` removes any prior image and volume, then builds the hardened Docker image:

```sh
./bin/build.sh
```

The image is tagged `local/codewhale:v${CODEWHALE_VERSION}-hardened` and extends `ghcr.io/hmbown/codewhale:v${CODEWHALE_VERSION}` (version read from `~/.config/codewhale/env`).

## Run

`bin/run.sh` handles the full lifecycle:

1. Loads API credentials and the pinned version from `~/.config/codewhale/env`
2. Parses the workspace path and container command (split on `--`)
3. Creates a persistent volume for CodeWhale state (`codewhale-home`)
4. Launches the container with network admin capabilities and workspace mount

`--` separates the workspace path (before) from the container command (after).

```sh
./bin/run.sh                          # Launch TUI in current directory
./bin/run.sh -- bash                  # Drop into a shell in current directory
./bin/run.sh /path/to/project         # Launch TUI in specified directory
./bin/run.sh /path/to/project -- bash # Shell in specified directory
./bin/run.sh -- codewhale --help      # Pass arguments to codewhale CLI

# Provider wrappers — same args as run.sh, auto-set via CODEWHALE_PROVIDER
./scripts/deepseek                        # Launch with DeepSeek
./scripts/deepseek /path/to/project       # DeepSeek in specific workspace
./scripts/qwen                            # Launch with Qwen (DashScope)
./scripts/qwen /path/to/project           # Qwen in specific workspace
```

## Architecture

```
bin/
├── build.sh              → Builds the Docker image
├── run.sh                → Orchestrates container launch
└── consolidate-tools.sh  → Copies session tools into docker/tools.d/
scripts/
├── deepseek              → Wrapper: launch with DeepSeek provider
└── qwen                  → Wrapper: launch with Qwen (DashScope) provider
docker/
├── Dockerfile            → Image definition (extends upstream, adds hardening)
└── entrypoint.sh         → Runtime hardening script (iptables, UID remap, permissions)
```

### Security Hardening

| Measure | Detail |
|---------|--------|
| Network isolation | Blocks outbound access to private IPv4 ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) and cloud metadata endpoints (169.254.169.254) via iptables |
| User remapping | Dynamically matches the container's `codewhale` user UID/GID to the host directory owner, preserving file ownership |
| Volume permissions | Force-chowns the CodeWhale state volume on every startup so remapped UIDs always own their data |
| Capability scoping | Only `NET_ADMIN` is added; all other capabilities remain at Docker's default restricted set |
| DNS pinning | Container DNS is pinned to Cloudflare (1.1.1.1) and Google (8.8.8.8) to avoid local resolver leaks |
| Sandbox mode | `CODEWHALE_EXECPOLICY=strict` enforces execution policy inside the agent |

## Customization

- **Different image version**: set `CODEWHALE_VERSION` in `~/.config/codewhale/env`, then rebuild with `./bin/build.sh`
- **Additional apt packages**: add them to the `RUN apt-get install` line in `docker/Dockerfile`
- **Network rules**: modify the iptables blocks in `docker/entrypoint.sh`
- **Entrypoint behavior**: the entrypoint routes to `codewhale-tui` by default; pass `bash` or `sh` as the first argument to override
- **Provider switching**: use `/provider deepseek`, `/provider openai` (Qwen OpenAI-compatible), or `/provider anthropic` (Qwen Anthropic-compatible) inside a session. Provider credentials are passed through `run.sh` from `~/.config/codewhale/env`.

## Upgrading

To move to a newer CodeWhale version, follow [UPDATE.md](UPDATE.md) — the full
playbook covering the vulnerability and 7-day age gates, the env-version change,
rebuild, smoke-test, and rollback steps.

## License

No license specified. Review upstream [CodeWhale](https://github.com/hmbown/codewhale) licensing before redistribution.