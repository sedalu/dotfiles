# Repository layout

Tooling configuration lives under `.config/`.
The project root is reserved for two kinds of file:
those that cannot be redirected,
and those a tool expects in a fixed place.

Root may hold:

| Path                  | Why it stays                                                        |
| --------------------- | ------------------------------------------------------------------- |
| `.gitignore`          | Git reads it only from the worktree                                 |
| `.claude/`, `.mcp.json` | Claude Code's fixed discovery paths                               |
| `.forgejo/`, `.github/` | The forge's fixed discovery path                                  |
| Build manifests       | `go.mod`, `Cargo.toml`, `package.json` — the toolchain requires them |
| The project's subject | Source trees, and the artifact the repo exists to define             |

The artifact a repo exists to define stays at the root even where it could be redirected.
A `compose.yaml` can be moved with `COMPOSE_FILE`,
but in a repo that exists to define a stack it is the subject, not tooling for it.

Machine-specific files end in `.local.*` and are gitignored:
`.config/mise.local.toml`, `.config/pitchfork.local.toml`, `.claude/settings.local.json`.

## Where a config file goes

Tooling config belongs in `.config/`.
How it gets there depends on what the tool supports, in this order:

1. **Native search covers `.config/`** — put the file there and stop.
2. **An environment variable names the config** — put the file in `.config/`
   and set the variable in the mise config,
   so every invocation picks it up.
3. **Only a flag names the config** — put the file in `.config/`
   and commit a wrapper to `.config/mise/bin/` that supplies the flag:

   ```sh
   #!/usr/bin/env bash
   set -euo pipefail
   exec "$(mise which gosec)" -conf "$PROJECT_ROOT/.config/gosec.json" "$@"
   ```

   Declare both halves in the mise config:

   ```toml
   [env]
   _.path = [".config/mise/bin"]
   PROJECT_ROOT = "{{config_root}}"
   ```

   mise places `_.path` entries ahead of the tool install directories,
   which is what lets a wrapper shadow the tool it wraps.
   Resolve the real binary with `mise which`,
   because anything resolving through `PATH` — `mise exec` included — finds the wrapper again.
   Name the config through `PROJECT_ROOT` rather than a relative path,
   which would resolve against the caller's working directory.

   A flag passed at one call site fixes only that call site;
   a wrapper fixes every invocation, an interactive one included.
4. **No override at all** — leave the file in its native location.

Linter sidecars follow the same ladder; most land on rule 2 or rule 3.

Three tools are worth naming:

- **mise** — always the directory form, `.config/mise/config.toml`.
  It is discovered natively and outranks `.mise/config.toml`.
  Tasks live in `.config/mise/tasks/`, and the lockfile lands beside the config.
  Early-init settings — the ones mise resolves before it reads any config,
  such as `override_config_filenames` and `ignored_config_paths` —
  go in `.config/miserc.toml`, which mise finds by walking up from the working directory.
- **fnox** — searches by filename against each ancestor directory
  and binds no environment variable, so it lands on rule 3.
  A `.config/fnox.toml` reached through a wrapper forfeits the `.local.toml` overlay,
  which fnox maps only for the bare filenames.
- **Renovate** — its repository-config list is fixed and has no `.config/` entry,
  so it lands on rule 4: `renovate.json5` under the forge directory, `.forgejo/` or `.github/`.
  Set `managerFilePatterns` explicitly for the mise manager so it finds the moved config.

A linter whose config is not found does not fail — it silently uses the tool's defaults.
Verify a moved config by asserting a rule the project *disables*:
a long Markdown line must still pass.
Never verify by observing that the linter ran and was quiet.
