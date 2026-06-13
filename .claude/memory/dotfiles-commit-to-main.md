---
name: dotfiles-commit-to-main
description: "In the ~/.config dotfiles repo, commit directly to main — do not create a branch first"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f768ff46-92de-4cf7-b5e4-11b8aafb40c6
---

In the dotfiles repo (`$DOTFILES_DIR` / `~/.config`, the bare-worktree setup), commit directly to `main`. Do NOT create a feature branch before committing, even though main is the default branch.

**Why:** This is a personal dotfiles repo; routine maintenance lands on main. The generic "branch before committing on the default branch" rule does not apply here. Worktree branches (`worktree:branch`) exist for parallel *development* work, not for ordinary dotfiles edits.

**How to apply:** When the user says "commit this" while on `main` in `~/.config`, just commit to `main`. Reserve branches for when the user explicitly asks for a worktree/branch.
