# Upgrade Guide — CodeWhale Version Bumps

How to safely move this hardened workspace to a new CodeWhale version. The
version is **not** hardcoded anywhere — it lives in one place and is read by
the build/run scripts.

## TL;DR

```sh
# 1. Verify the target version is safe (see "Decision gates" below)
# 2. Change the version in one place:
edit ~/.config/codewhale/env        # CODEWHALE_VERSION="x.y.z"
# 3. Rebuild and smoke-test:
./bin/build.sh
./bin/run.sh -- codewhale --version
# 4. Roll back instantly if anything regresses:
#    set CODEWHALE_VERSION back, re-run ./bin/build.sh
```

## Where the version lives

- **Single source of truth**: `CODEWHALE_VERSION` in `~/.config/codewhale/env`
  (started from `env.sample`, which currently ships `"0.8.66"`).
- `bin/build.sh` sources the env, passes `--build-arg CODEWHALE_VERSION` to the
  Docker build, and tags `local/codewhale:v${CODEWHALE_VERSION}-hardened`.
- `bin/run.sh` sources the env and launches `local/codewhale:v${CODEWHALE_VERSION}-hardened`.
- `docker/Dockerfile` uses `ARG CODEWHALE_VERSION` (required, no default) in
  `FROM ghcr.io/hmbown/codewhale:v${CODEWHALE_VERSION}`.

Do **not** edit the version in `Dockerfile`, `build.sh`, or `run.sh` — the env
value is the only knob.

## Trying a version without editing env

Export `CODEWHALE_VERSION` in the shell to override the pinned value without
touching `~/.config/codewhale/env` (the scripts honor the shell override):

```sh
export CODEWHALE_VERSION=0.9.7   # or: CODEWHALE_VERSION=0.9.7 ./bin/build.sh
./bin/build.sh && ./bin/run.sh
```

The override is shell-only and never writes to the env file; run the normal
build/run (no override) to return to the pinned version.

## Decision gates

Apply all three before committing to a target version.

### 1. Vulnerability gate (hard floor)

Only published GitHub Security Advisories are covered here. Check them:

```sh
curl -s "https://api.github.com/repos/hmbown/codewhale/security-advisories?per_page=30" \
  | jq -r '.[] | select(.withdrawn_at == null) | [.ghsa_id, .severity, (.summary[:70]), ([.vulnerabilities[]? | select(.package.name == "codewhale" or .package.name == "codewhale-tui") | .vulnerable_version_range] | unique | join(", "))] | @tsv'
```

Rules:

- The **floor** is the highest upper bound of any non-withdrawn advisory.
  As of the last review, every advisory on the `codewhale` package is fixed in
  **v0.8.64** (all ranges are `< 0.8.64`), so `>= 0.8.64` is clean.
- Never run below that floor. If a *new* advisory appears with a higher
  `first_patched_version`, the floor moves up — re-run the check each time.
- "Safe" here means "no **published** advisory". An unpublished/advisory-less
  flaw can still exist; a fresh release also carries that risk (see gate 3).

### 2. Age gate (released > 7 days ago)

A release must have been published **more than 7 days** before you adopt it, to
let the fast 0.9.x churn settle. List releases with dates:

```sh
curl -s "https://api.github.com/repos/hmbown/codewhale/releases?per_page=30" \
  | jq -r '.[] | [.tag_name, .published_at, (if .prerelease then "prerelease" else "stable" end)] | @tsv'
```

Rules:

- Consider only **stable** (non-prerelease) releases.
- Filter to `published_at` older than 7 days from today.
- Pick the newest remaining.

### 3. Minor-version caution (0.8 → 0.9)

A **minor** bump can carry breaking changes. The hardening in
`docker/entrypoint.sh` (iptables, UID remap, `gosu` drop, command routing)
depends on the upstream image's layout and behaviors. Before adopting a new
minor line:

- Read the release notes / `CHANGELOG.md` for the target:
  ```sh
  curl -s "https://api.github.com/repos/hmbown/codewhale/releases/tags/vX.Y.Z" | jq .
  ```
- Prefer the newest **patch** on a line you have already smoke-tested.

## Step-by-step upgrade

1. **Snapshot current state** — note the current `CODEWHALE_VERSION` so you can
   roll back.
2. **Run the two checks above** (advisories + releases) and apply the gates.
3. **Review release notes** for the chosen tag (breaking changes, hardening
   changes, config/sandbox defaults).
4. **Edit the version** in `~/.config/codewhale/env`:
   ```sh
   export CODEWHALE_VERSION="x.y.z"
   ```
5. **Rebuild** (optionally `-f` to also wipe the `codewhale-home` state volume):
   ```sh
   ./bin/build.sh          # rebuild only
   ./bin/build.sh -f       # rebuild AND nuke the state volume (loses history)
   ```
6. **Smoke-test**:
   ```sh
   ./bin/run.sh -- codewhale --version   # confirm the new version boots
   ./bin/run.sh -- bash                  # drop into a shell to inspect hardening
   ```
7. **Verify hardening still applies** (in the shell from step 6):
   - iptables private-range blocks are present
   - the process runs as the remapped `codewhale` UID (not root) after entrypoint
   - `CODEWHALE_EXECPOLICY=strict` is in effect
8. **Commit** the change (env is outside the repo; the repo only needs commits
   if `env.sample`, docs, or scripts change).

## Rollback

```sh
# Put the previous version back and rebuild:
edit ~/.config/codewhale/env        # CODEWHALE_VERSION="<previous>"
./bin/build.sh
```

No other change is needed — the old tag is still pulled from GHCR and rebuilt.

## Gotchas

- **`./bin/build.sh -f` nukes the `codewhale-home` volume.** It deletes agent
  state (conversations/config/notes). Only use it for a clean rebuild; plain
  `./bin/build.sh` preserves the volume.
- **The floor can move.** `v0.8.64` is the floor *as of the last review*; a new
  advisory raises it. Re-check advisories before every upgrade.
- **0.9.x releases fast.** As of the last review there were ~4 stable releases
  in 8 days — a sign the line is still stabilizing. Holding a week (the age
  gate) is the cheap way to let that settle.
- **Published-only coverage.** No advisory list proves a version has no flaws;
  it only proves no flaw has been *published*. Treat brand-new releases as
  higher-risk regardless.

## Status snapshot (reviewed 2026-08-21)

- **Pinned**: `v0.8.66`
- **Vulnerability floor**: `v0.8.64` (all published `codewhale` advisories fixed here)
- **Latest safe 0.8.x**: `v0.8.67` (2026-07-07)
- **Latest stable release**: `v0.9.10` (2026-08-20) — fails the 7-day age gate
- **Latest release clearing both gates**: `v0.9.7` (2026-08-13, ~8 days old)

These are point-in-time facts — re-run the checks before acting on them.