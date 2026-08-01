---
name: feedback-shell-config-portable-guards
description: Shell config edits must no-op on machines lacking the tool; prefer a guarded function over PATH shimming
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b1374809-1a08-444a-89fc-b37e05560252
  modified: 2026-08-01T03:09:40.133Z
---

Anything added to `shell/` must be robust and portable.
Guard the definition on an exported env var (or tool presence)
so the shell provides nothing on a machine where that tool isn't installed,
and avoid PATH manipulation when a narrower mechanism exists.

**Why:** the dotfiles are shared across machines where a given tool (cmux, claude, …) may be absent,
so an unconditional definition leaks a phantom command.
PATH ordering is also unreliable here — `mise activate` re-prepends its `installs/*` dirs
and buries anything set earlier in `.zshenv`/`.zprofile`.

**How to apply:** wrap it in `if [[ -n "${TOOL_ENV_VAR:-}" ]]; then … fi` rather than defining unconditionally;
use `${VAR:-}` defaults throughout so it stays `set -u` safe;
prefer a shell function over inserting a directory into `PATH`.
The `claude()` cmux wrapper in `shell/interactive.sh` is the reference example.
Related: [[feedback-config-authoring-style]].
