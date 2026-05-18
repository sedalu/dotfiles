---
name: feedback-mise-trust
description: "Run `mise trust` after creating a worktree, clone, or entering a new directory that has a mise config"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 8b9ae04b-0cae-4862-801d-f454b2a6ff91
---

Run `mise trust` whenever entering a new directory context that has a mise config: after creating a git worktree, after cloning a repo, or when working in a new dir with a `mise.toml` / `mise/config.toml`.

**Why:** Without trust, mise refuses to parse the config and operations fail — e.g., EnterWorktree errored mid-creation because the worktree's mise config was untrusted.

**How to apply:** Before or immediately after switching into a worktree or new repo context, run `mise trust` (or `mise trust <path>`) so mise can load its config without errors.
