---
name: project_mise_raw_task_sudo_tty
description: mise task raw=true fixes sudo-prompt-needs-TTY failures but drops output prefixing for that task
metadata: 
  node_type: memory
  type: project
  originSessionId: 67f14828-9990-4c45-815d-58da5202b827
---

`update:mise` (`.config/mise/tasks/update/mise`) needed `#MISE raw=true`.
`mise bootstrap packages upgrade` can trigger `sudo installer -pkg` for pkg-based casks (e.g. tailscale-app).
The `update` aggregator sets `MISE_TASK_OUTPUT=prefix` for its parallel subtasks,
which pipes stdio instead of inheriting the terminal —
mise's internal `sudo::run()` (`src/system/sudo.rs`) then sees no TTY on stderr
and errors instead of prompting for a password.
`raw=true` makes that one task bypass the piped/prefixed execution path
and inherit real stdio (`execute_raw()` in mise's `cmd.rs`), so the sudo prompt works.
See [[project_mise_bootstrap_migration]].

**Why it matters for future debugging:**
confirmed empirically that a `raw=true` task's own output loses its `[taskname]` prefix entirely
(mise's `MISE_TASK_OUTPUT=prefix` env var doesn't override the raw execution path,
only the non-raw print-style path).
Per mise's docs/source, `raw=true` also serializes that task against any other task running in parallel
(RWMutex write lock) — acceptable for an occasional `update` run, but not for high-frequency parallel tasks.

**How to apply:** if a mise task's subprocess needs an interactive prompt (sudo password, or anything else
reading stdin/writing to a real TTY) and it's invoked from a context that pipes/prefixes output
(parallel `mise run 'name:*'`, `MISE_TASK_OUTPUT=prefix`, etc.), mark that specific task `raw=true`
rather than wrapping the outer `mise run` invocation in `sudo` —
wrapping the whole tree in `sudo` strips custom env vars (env_reset) and breaks anything
downstream that reads them unguarded (e.g. `DOTFILES_DIR` in `install:macos`).
