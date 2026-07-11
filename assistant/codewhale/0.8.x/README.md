# CodeWhale Hardened Workspace

Hardened Docker workspace for [CodeWhale](https://github.com/hmbown/codewhale) v0.8.66 — a containerized AI coding agent with network isolation, user remapping, and terminal TUI execution.

## Prerequisites

- Docker (with BuildKit support)
- A [DeepSeek API key](https://platform.deepseek.com/) set in `~/.deepseek/env`:
  ```sh
  export DEEPSEEK_API_KEY="sk-..."
  ```

## Quick Start

```sh
# Build the hardened image
./build.sh

# Launch a CodeWhale TUI session in the current directory
./run.sh
```

## Build

`build.sh` removes any prior image and volume, then builds the hardened Docker image:

```sh
./build.sh
```

The image is tagged `local/codewhale:v0.8.66-hardened` and extends `ghcr.io/hmbown/codewhale:v0.8.66`.

## Run

`run.sh` handles the full lifecycle:

1. Loads your DeepSeek API key from `~/.deepseek/env`
2. Parses the workspace path and container command (split on `--`)
3. Creates a persistent volume for CodeWhale state (`codewhale-home`)
4. Launches the container with network admin capabilities and workspace mount

`--` separates the workspace path (before) from the container command (after).

```sh
./run.sh                          # Launch TUI in current directory
./run.sh -- bash                  # Drop into a shell in current directory
./run.sh /path/to/project         # Launch TUI in specified directory
./run.sh /path/to/project -- bash # Shell in specified directory
./run.sh -- codewhale --help      # Pass arguments to codewhale CLI
```

## Architecture

```
build.sh          → Builds the Docker image
run.sh            → Orchestrates container launch
docker/
├── Dockerfile    → Image definition (extends upstream, adds hardening)
└── entrypoint.sh → Runtime hardening script (iptables, UID remap, permissions)
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

- **Different image version**: edit the tag in `build.sh` and `run.sh`
- **Additional apt packages**: add them to the `RUN apt-get install` line in `docker/Dockerfile`
- **Network rules**: modify the iptables blocks in `docker/entrypoint.sh`
- **Entrypoint behavior**: the entrypoint routes to `codewhale-tui` by default; pass `bash` or `sh` as the first argument to override

## License

No license specified. Review upstream [CodeWhale](https://github.com/hmbown/codewhale) licensing before redistribution.
