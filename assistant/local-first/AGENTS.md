# AGENTS.md — local-first

This file is instruction for AI agents (CodeWhale, Claude, etc.) working in this repository.

## Project structure

- `docker-compose.yml` — Ollama + LiteLLM containers
- `.env` — secrets, gitignored; template at `env.example`
- `config/litellm.yaml` — model routing (local Ollama + remote APIs)
- `config/aichat.yaml` — aichat client configuration
- `config/aliases.sh` — shell aliases for `ai`, `ai-fast`, etc.
- `bin/` — lifecycle scripts (start, stop, restart, status, etc.)

## Key rules

1. **Never commit `.env`.** The template is `env.example`.
2. **Config lives in `config/`.** No config files at project root except `docker-compose.yml`.
3. **Scripts live in `bin/`.** No shell scripts at project root.
4. **Model names** in `config/aichat.yaml` and `config/aliases.sh` must match `model_name` fields in `config/litellm.yaml`.
5. **Image SHAs** in `.env` are amd64 platform digests (not manifest list digests). The verify script extracts these from the registry.
6. **All scripts resolve paths relative to themselves** (use `SCRIPT_DIR` / `BIN_DIR` patterns). They work from any CWD.

## Adding a local model

1. Add entry in `config/litellm.yaml` under `model_list` with `model: openai/<ollama-model-name>`
2. Add matching entry in `config/aichat.yaml` under `clients[0].models`
3. Optional: add alias in `config/aliases.sh`
4. The model will be pulled automatically on next `./bin/start.sh` (via `pull-local-models.sh` which reads `openai/` entries from `config/litellm.yaml`)

## Adding a remote model

1. Add entry in `config/litellm.yaml` under `model_list`
2. Ensure API key is set in `.env` and wired in `docker-compose.yml` environment
3. Add matching entry in `config/aichat.yaml`
4. Restart LiteLLM: `docker compose restart litellm`

## Version pinning

Image versions are pinned by tag + SHA256 in `.env`. The `verify-image-sha.sh` script cross-checks against registries. Both use platform-specific (amd64) digests.
