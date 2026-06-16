---
name: feedback-xdg-classify-by-data
description: "When XDG-relocating a tool's dir, classify by what the data IS, not reflexively XDG_CONFIG_HOME"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e257b28d-2bfa-4ec3-8aab-c2b44490b400
---

When relocating a tool's home dir for XDG compliance in this dotfiles repo, classify by *what the data is*, don't reflexively reach for `XDG_CONFIG_HOME`.

**Why:** `XDG_CONFIG_HOME` == the dotfiles worktree (`~/.config`), so anything pointed there lands *in the repo* and needs a gitignore entry. Machine state doesn't belong in the repo at all.

**How to apply:**
- Machine state (current context, app runtime state, history) → `XDG_STATE_HOME` (`~/.local/state`) — stays out of the worktree, no gitignore needed. (e.g. `DOCKER_CONFIG`, vim `viminfo`)
- Regenerable cache → `XDG_CACHE_HOME` (e.g. `NPM_CONFIG_CACHE`)
- Real, portable config → `XDG_CONFIG_HOME` (in the worktree); deny-by-default in `.gitignore` only if it's secret-prone (e.g. npm `.npmrc` writes auth tokens — mirror the `fnox/` pattern).
- Tool data → `XDG_DATA_HOME` (e.g. `CARGO_HOME`, `RUSTUP_HOME`, `BUN_INSTALL`).

Established refactoring stray `~/` dirs (commit 85c7c3f). See [[dotfiles-commit-to-main]].
