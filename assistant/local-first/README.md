# local-first

Local LLM inference with automatic remote escalation. Ollama runs Qwen2.5-Coder models locally; LiteLLM acts as an OpenAI-compatible proxy and routes to remote APIs when needed.

## Architecture

```
aichat ──→ 127.0.0.1:4000 (LiteLLM) ──→ ollama:11434 (local-14b, local-7b)
                              ├──→ DeepSeek API (remote-deepseek)
                              ├──→ Gemini API  (remote-gemini)
                              └──→ Copilot     (remote-copilot)
```

| Model | Provider | Use |
|---|---|---|
| `local-14b` | Ollama — qwen2.5-coder:14b | Primary reasoning, architecture |
| `local-7b` | Ollama — qwen2.5-coder:7b | Fast tasks, quick edits |
| `remote-deepseek` | DeepSeek API | Remote escalation |
| `remote-gemini` | Gemini 1.5 Pro | Large-context reasoning |
| `remote-copilot` | GitHub Copilot | Remote escalation |

## Quickstart

```bash
cp env.example .env
# Edit .env — add DEEPSEEK_API_KEY and GEMINI_API_KEY

./bin/start.sh
./bin/status.sh
```

Source the aliases:

```bash
source config/aliases.sh
```

Then:

```bash
ai "explain this code"        # local-14b
ai-fast "fix this typo"       # local-7b
```

## Commands

| Script | Does |
|---|---|
| `./bin/start.sh` | Verify SHAs → start containers → pull models |
| `./bin/stop.sh` | Stop and remove containers |
| `./bin/restart.sh` | Stop then start |
| `./bin/status.sh` | Container health, cached models, latency test |
| `./bin/pull-local-models.sh` | Pull/update local Ollama model weights |
| `./bin/verify-image-sha.sh` | Verify Docker image digests against `.env` |

## Files

```
├── docker-compose.yml
├── .env                        # secrets (gitignored)
├── env.example                 # template
├── config/
│   ├── litellm.yaml            # LiteLLM model routing
│   ├── aichat.yaml             # aichat client config
│   └── aliases.sh              # shell aliases
└── bin/
    ├── start.sh
    ├── stop.sh
    ├── restart.sh
    ├── status.sh
    ├── verify-image-sha.sh
    └── pull-local-models.sh
```

## Adding a model

1. Add to `config/litellm.yaml` under `model_list`
2. Add to `config/aichat.yaml` under `clients[0].models`
3. Optional — add an alias in `config/aliases.sh`
4. Restart: `./bin/restart.sh`
