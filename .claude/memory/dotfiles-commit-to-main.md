---
name: dotfiles-commit-to-main
description: "In the ~/.config dotfiles repo, commit directly to main — do not create a branch first"
metadata:
  node_type: memory
  type: feedback
  originSessionId: f768ff46-92de-4cf7-b5e4-11b8aafb40c6
  modified: 2026-09-04T15:55:13.155Z
---

In the dotfiles repo (`$DOTFILES_DIR` / `~/.config`), commit directly to `main`. Do NOT create a feature branch before committing, even though main is the default branch.

**Why:** The standard is that all work happens on a branch (`docs/dev-standards/git.md`), and this checkout is a declared exception because it is a live installation — the tree *is* `$XDG_CONFIG_HOME`, read in place, so it cannot move to make room for a `main/` sibling. The exception is recorded as `defaultBranch.allowDirectCommits` in this clone's local git config, which `claude/hooks/default-branch-guard.sh` reads.

**How to apply:** When the user says "commit this" while on `main` in `~/.config`, just commit to `main`. Everywhere the key is unset the hook denies the edit, so branch first. Never set that key yourself — the hook denies it and hands the command to the user. See [[feedback-never-rewrite-commits]] and [[feedback-hand-off-commands-last]].
